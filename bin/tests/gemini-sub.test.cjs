const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const { spawnSync } = require('node:child_process')

test('gemini-sub CLI argument parsing, key resolution, and error handling', () => {
  const root = fs.mkdtempSync(path.join(__dirname, '.gemini-sub-test-'))
  const binPath = path.join(__dirname, '../gemini-sub')

  try {
    // 1. Missing repo
    const r1 = spawnSync(process.execPath, [binPath], { encoding: 'utf8' })
    assert.equal(r1.status, 2)
    assert.match(r1.stderr, /--repo is required/)

    // 2. Missing prompt
    const r2 = spawnSync(process.execPath, [binPath, '--repo', root], { encoding: 'utf8' })
    assert.equal(r2.status, 2)
    assert.match(r2.stderr, /--prompt is required/)

    // 3. Invalid effort
    const r3 = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'hello', '--effort', 'super'], { encoding: 'utf8' })
    assert.equal(r3.status, 2)
    assert.match(r3.stderr, /invalid effort/)

    // 4. Missing API key
    const r4 = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'hello'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root }, // HOME points to empty temp dir
    })
    assert.equal(r4.status, 2)
    const out4 = JSON.parse(r4.stdout.trim().split('\n').pop())
    assert.equal(out4.code, 'AUTH_MISSING')
    assert.equal(out4.ok, false)

    // 5. Key resolution from ~/.config/gemini-sub/.env
    const configDir = path.join(root, '.config', 'gemini-sub')
    fs.mkdirSync(configDir, { recursive: true })
    fs.writeFileSync(path.join(configDir, '.env'), 'GEMINI_API_KEY="test-key-from-env-file"  # comment with 日本語\n')

    const r5 = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'hello', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(r5.status, 0, r5.stderr)
    const out5 = JSON.parse(r5.stdout.trim().split('\n').pop())
    assert.equal(out5.ok, true)
    assert.equal(out5.hasKey, true)
    assert.equal(out5.model, 'gemini-4-hydrogen')
    assert.equal(out5.effort, 'high')
    assert.equal(out5.thinkingConfig.thinkingLevel, 'high') // default high for hydrogen

    // 5b. xhigh thinkingLevel on gemini-4-hydrogen
    const r5b = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'hello', '--model', 'gemini-4-hydrogen', '--effort', 'xhigh', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(r5b.status, 0, r5b.stderr)
    const out5b = JSON.parse(r5b.stdout.trim().split('\n').pop())
    assert.equal(out5b.effort, 'xhigh')
    assert.equal(out5b.thinkingConfig.thinkingLevel, 'xhigh')

    // 5c. Non-Hydrogen models still default to medium when --effort is omitted
    const r5c = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'hello', '--model', 'gemini-4-argon', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(r5c.status, 0, r5c.stderr)
    const out5c = JSON.parse(r5c.stdout.trim().split('\n').pop())
    assert.equal(out5c.model, 'gemini-4-argon')
    assert.equal(out5c.effort, 'medium')
    assert.equal(out5c.thinkingConfig.thinkingLevel, 'medium')

    // 6. Gemini 2.5 numeric thinkingBudget mapping when explicitly specified
    const r6 = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'hello', '--model', 'gemini-2.5-pro', '--effort', 'high', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(r6.status, 0)
    const out6 = JSON.parse(r6.stdout.trim().split('\n').pop())
    assert.equal(out6.thinkingConfig.thinkingBudget, 32768)

    // 7. Explicit --key-file argument
    const customKeyFile = path.join(root, 'custom.env')
    fs.writeFileSync(customKeyFile, 'GEMINI_API_KEY=explicit-custom-key\n')
    const r7 = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'hello', '--key-file', customKeyFile, '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: path.join(root, 'empty-home') },
    })
    assert.equal(r7.status, 0)
    const out7 = JSON.parse(r7.stdout.trim().split('\n').pop())
    assert.equal(out7.hasKey, true)
  } finally {
    fs.rmSync(root, { recursive: true, force: true })
  }
})

test('gemini-sub fetch mocking: SSE stream, thought filtering, 429 quota exhaustion, auth failure, and timeout', () => {
  const root = fs.mkdtempSync(path.join(__dirname, '.gemini-sub-mock-'))
  const binPath = path.join(__dirname, '../gemini-sub')
  const preloadPath = path.join(root, 'preload.cjs')

  // Create preload script to mock globalThis.fetch cleanly without network sockets
  fs.writeFileSync(preloadPath, `
const mode = process.env.MOCK_FETCH_MODE;
if (mode) {
  const enc = new TextEncoder();
  globalThis.fetch = async (url, options) => {
    if (!url.includes(':streamGenerateContent?alt=sse')) {
      throw new Error('Expected SSE endpoint, got: ' + url);
    }
    if (mode === 'success') {
      return {
        ok: true,
        status: 200,
        json: async () => ({
          candidates: [{ content: { parts: [{ text: 'Mock response text' }] } }],
          usageMetadata: { promptTokenCount: 12, candidatesTokenCount: 6, totalTokenCount: 18 },
        }),
      };
    }
    if (mode === 'sse') {
      const ssePayload = [
        ': keepalive\\n\\n',
        'data: ' + JSON.stringify({ candidates: [{ content: { parts: [{ text: 'secret thought', thought: true }] } }], usageMetadata: { promptTokenCount: 10, thoughtsTokenCount: 50, totalTokenCount: 60 } }) + '\\n\\n',
        'data: ' + JSON.stringify({ candidates: [{ content: { parts: [{ text: 'Hello ' }] } }], usageMetadata: { promptTokenCount: 10, thoughtsTokenCount: 50, candidatesTokenCount: 1, totalTokenCount: 61 } }) + '\\n\\n',
        'data: ' + JSON.stringify({ candidates: [{ content: { parts: [{ text: '世界!' }] } }], usageMetadata: { promptTokenCount: 10, thoughtsTokenCount: 50, candidatesTokenCount: 3, totalTokenCount: 63 } }) + '\\n\\n',
        'data: [DONE]\\n\\n',
      ].join('');
      const bytes = enc.encode(ssePayload);
      const mid = Math.floor(bytes.length / 2);
      const body = new ReadableStream({
        start(controller) {
          controller.enqueue(bytes.slice(0, mid));
          controller.enqueue(bytes.slice(mid));
          controller.close();
        },
      });
      return { ok: true, status: 200, body };
    }
    if (mode === 'sse_quota') {
      const ssePayload = 'data: ' + JSON.stringify({ error: { code: 429, message: 'Stream quota exhausted', status: 'RESOURCE_EXHAUSTED' } }) + '\\n\\n';
      const body = new ReadableStream({
        start(controller) {
          controller.enqueue(enc.encode(ssePayload));
          controller.close();
        },
      });
      return { ok: true, status: 200, body };
    }
    if (mode === 'quota') {
      return {
        ok: false,
        status: 429,
        json: async () => ({
          error: { code: 429, message: 'Resource has been exhausted', status: 'RESOURCE_EXHAUSTED' },
        }),
      };
    }
    if (mode === 'auth') {
      return {
        ok: false,
        status: 401,
        json: async () => ({
          error: { code: 401, message: 'API key not valid', status: 'UNAUTHENTICATED' },
        }),
      };
    }
    if (mode === 'hang') {
      return new Promise((resolve, reject) => {
        const timer = setTimeout(() => {
          resolve({ ok: true, status: 200, json: async () => ({}) });
        }, 5000);
        if (options && options.signal) {
          options.signal.addEventListener('abort', () => {
            clearTimeout(timer);
            const err = new Error('The operation was aborted');
            err.name = 'AbortError';
            reject(err);
          });
        }
      });
    }
    if (mode === 'stream_hang') {
      const body = new ReadableStream({
        start(controller) {
          controller.enqueue(enc.encode(': keepalive\\n\\n'));
          if (options && options.signal) {
            options.signal.addEventListener('abort', () => {
              const err = new Error('The operation was aborted');
              err.name = 'AbortError';
              controller.error(err);
            });
          }
        },
      });
      return { ok: true, status: 200, body };
    }
    throw new Error('Unknown mock mode: ' + mode);
  };
}
`)

  try {
    // 1. Legacy non-body JSON fallback
    const rSuccess = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'mock task'], {
      encoding: 'utf8',
      env: {
        PATH: process.env.PATH,
        NODE_OPTIONS: `--require=${preloadPath}`,
        MOCK_FETCH_MODE: 'success',
        GEMINI_API_KEY: 'test-key',
      },
    })
    assert.equal(rSuccess.status, 0, rSuccess.stderr)
    const outSuccess = JSON.parse(rSuccess.stdout.trim().split('\n').pop())
    assert.equal(outSuccess.ok, true)
    assert.equal(outSuccess.text, 'Mock response text')
    assert.equal(outSuccess.usage.totalTokenCount, 18)

    // 1b. SSE ReadableStream with split UTF-8 chunk & thought filtering
    const rSse = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'mock task'], {
      encoding: 'utf8',
      env: {
        PATH: process.env.PATH,
        NODE_OPTIONS: `--require=${preloadPath}`,
        MOCK_FETCH_MODE: 'sse',
        GEMINI_API_KEY: 'test-key',
      },
    })
    assert.equal(rSse.status, 0, rSse.stderr)
    const outSse = JSON.parse(rSse.stdout.trim().split('\n').pop())
    assert.equal(outSse.ok, true)
    assert.equal(outSse.text, 'Hello 世界!')
    assert.equal(outSse.usage.totalTokenCount, 63)

    // 1c. Mid-stream SSE error chunk (RESOURCE_EXHAUSTED)
    const rSseQuota = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'mock task'], {
      encoding: 'utf8',
      env: {
        PATH: process.env.PATH,
        NODE_OPTIONS: `--require=${preloadPath}`,
        MOCK_FETCH_MODE: 'sse_quota',
        GEMINI_API_KEY: 'test-key',
      },
    })
    assert.equal(rSseQuota.status, 3)
    const outSseQuota = JSON.parse(rSseQuota.stdout.trim().split('\n').pop())
    assert.equal(outSseQuota.code, 'USAGE_LIMIT')

    // 2. Quota / Prepay exhausted (429)
    const rQuota = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'mock task'], {
      encoding: 'utf8',
      env: {
        PATH: process.env.PATH,
        NODE_OPTIONS: `--require=${preloadPath}`,
        MOCK_FETCH_MODE: 'quota',
        GEMINI_API_KEY: 'test-key',
      },
    })
    assert.equal(rQuota.status, 3)
    const outQuota = JSON.parse(rQuota.stdout.trim().split('\n').pop())
    assert.equal(outQuota.ok, false)
    assert.equal(outQuota.code, 'USAGE_LIMIT')
    assert.match(outQuota.message, /Resource has been exhausted/)

    // 3. Auth Failure (401)
    const rAuth = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'mock task'], {
      encoding: 'utf8',
      env: {
        PATH: process.env.PATH,
        NODE_OPTIONS: `--require=${preloadPath}`,
        MOCK_FETCH_MODE: 'auth',
        GEMINI_API_KEY: 'bad-key',
      },
    })
    assert.equal(rAuth.status, 3)
    const outAuth = JSON.parse(rAuth.stdout.trim().split('\n').pop())
    assert.equal(outAuth.ok, false)
    assert.equal(outAuth.code, 'AUTH_FAILED')

    // 4. Timeout before headers (exit 4)
    const rTimeout = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'mock task', '--timeout', '0.2'], {
      encoding: 'utf8',
      env: {
        PATH: process.env.PATH,
        NODE_OPTIONS: `--require=${preloadPath}`,
        MOCK_FETCH_MODE: 'hang',
        GEMINI_API_KEY: 'test-key',
      },
    })
    assert.equal(rTimeout.status, 4)
    const outTimeout = JSON.parse(rTimeout.stdout.trim().split('\n').pop())
    assert.equal(outTimeout.ok, false)
    assert.equal(outTimeout.code, 'TIMEOUT')

    // 5. Timeout during SSE body read (exit 4)
    const rStreamTimeout = spawnSync(process.execPath, [binPath, '--repo', root, '--prompt', 'mock task', '--timeout', '0.2'], {
      encoding: 'utf8',
      env: {
        PATH: process.env.PATH,
        NODE_OPTIONS: `--require=${preloadPath}`,
        MOCK_FETCH_MODE: 'stream_hang',
        GEMINI_API_KEY: 'test-key',
      },
    })
    assert.equal(rStreamTimeout.status, 4)
    const outStreamTimeout = JSON.parse(rStreamTimeout.stdout.trim().split('\n').pop())
    assert.equal(outStreamTimeout.ok, false)
    assert.equal(outStreamTimeout.code, 'TIMEOUT')
  } finally {
    fs.rmSync(root, { recursive: true, force: true })
  }
})

test('argon-sub, carbon-sub, hydrogen-sub, and flash-sub shell wrappers dispatch with correct default models and effort', () => {
  const root = fs.mkdtempSync(path.join(__dirname, '.gemini-wrappers-test-'))
  const argonBin = path.join(__dirname, '../argon-sub')
  const carbonBin = path.join(__dirname, '../carbon-sub')
  const hydrogenBin = path.join(__dirname, '../hydrogen-sub')
  const flashBin = path.join(__dirname, '../flash-sub')

  try {
    const configDir = path.join(root, '.config', 'gemini-sub')
    fs.mkdirSync(configDir, { recursive: true })
    fs.writeFileSync(path.join(configDir, '.env'), 'GEMINI_API_KEY=test-key\n')

    // Test argon-sub defaults
    const rArgon = spawnSync(argonBin, ['--repo', root, '--prompt', 'hello', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(rArgon.status, 0, rArgon.stderr)
    const outArgon = JSON.parse(rArgon.stdout.trim().split('\n').pop())
    assert.equal(outArgon.model, 'gemini-4-argon')
    assert.equal(outArgon.effort, 'medium')
    assert.equal(outArgon.thinkingConfig.thinkingLevel, 'medium')

    // Test carbon-sub defaults
    const rCarbon = spawnSync(carbonBin, ['--repo', root, '--prompt', 'hello', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(rCarbon.status, 0, rCarbon.stderr)
    const outCarbon = JSON.parse(rCarbon.stdout.trim().split('\n').pop())
    assert.equal(outCarbon.model, 'gemini-4-carbon')
    assert.equal(outCarbon.effort, 'medium')
    assert.equal(outCarbon.thinkingConfig.thinkingLevel, 'medium')

    // Test hydrogen-sub defaults
    const rHydrogen = spawnSync(hydrogenBin, ['--repo', root, '--prompt', 'hello', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(rHydrogen.status, 0, rHydrogen.stderr)
    const outHydrogen = JSON.parse(rHydrogen.stdout.trim().split('\n').pop())
    assert.equal(outHydrogen.model, 'gemini-4-hydrogen')
    assert.equal(outHydrogen.effort, 'high')
    assert.equal(outHydrogen.thinkingConfig.thinkingLevel, 'high')

    // Test hydrogen-sub low override
    const rHydrogenLow = spawnSync(hydrogenBin, ['--repo', root, '--prompt', 'hello', '--effort', 'low', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(rHydrogenLow.status, 0, rHydrogenLow.stderr)
    const outHydrogenLow = JSON.parse(rHydrogenLow.stdout.trim().split('\n').pop())
    assert.equal(outHydrogenLow.effort, 'low')
    assert.equal(outHydrogenLow.thinkingConfig.thinkingLevel, 'low')

    // Test hydrogen-sub xhigh override
    const rHydrogenXhigh = spawnSync(hydrogenBin, ['--repo', root, '--prompt', 'hello', '--effort', 'xhigh', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(rHydrogenXhigh.status, 0, rHydrogenXhigh.stderr)
    const outHydrogenXhigh = JSON.parse(rHydrogenXhigh.stdout.trim().split('\n').pop())
    assert.equal(outHydrogenXhigh.effort, 'xhigh')
    assert.equal(outHydrogenXhigh.thinkingConfig.thinkingLevel, 'xhigh')

    // Test flash-sub defaults
    const rFlash = spawnSync(flashBin, ['--repo', root, '--prompt', 'hello', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(rFlash.status, 0, rFlash.stderr)
    const outFlash = JSON.parse(rFlash.stdout.trim().split('\n').pop())
    assert.equal(outFlash.model, 'gemini-3.8-flash')
    assert.equal(outFlash.effort, 'medium')
    assert.equal(outFlash.thinkingConfig.thinkingLevel, 'medium')

    // Test user override of effort on flash-sub
    const rOverride = spawnSync(flashBin, ['--repo', root, '--prompt', 'hello', '--effort', 'high', '--dry-run'], {
      encoding: 'utf8',
      env: { PATH: process.env.PATH, HOME: root },
    })
    assert.equal(rOverride.status, 0)
    const outOverride = JSON.parse(rOverride.stdout.trim().split('\n').pop())
    assert.equal(outOverride.effort, 'high')
    assert.equal(outOverride.thinkingConfig.thinkingLevel, 'high')
  } finally {
    fs.rmSync(root, { recursive: true, force: true })
  }
})
