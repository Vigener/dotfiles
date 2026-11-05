const { test } = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const { spawnSync } = require('node:child_process')

test('Codex-only wrapper preserves success and never calls the API fallback', () => {
  const root = fs.mkdtempSync(path.join(__dirname, '.codex-sub-test-'))
  try {
    const wrapper = path.join(root, 'codex-sub')
    fs.copyFileSync(path.join(__dirname, '../codex-sub'), wrapper)
    fs.symlinkSync('/bin/sh', path.join(root, 'sh'))
    const marker = path.join(root, 'api-called')
    const executable = (name, code) => {
      fs.writeFileSync(path.join(root, name), `#!${process.execPath}\n${code}`)
      fs.chmodSync(path.join(root, name), 0o755)
    }
    // A sibling dsh-sub sentinel also detects the old absolute fallback path.
    executable('dsh-sub', `require('node:fs').writeFileSync(${JSON.stringify(marker)}, 'called')`)
    // Avoid reading any real Codex configuration, authentication, or secrets.
    const preload = path.join(root, 'config.cjs')
    fs.writeFileSync(preload, `const fs = require('node:fs'); const read = fs.readFileSync;
fs.readFileSync = function(p, ...args) {
  if (String(p).endsWith('/.codex/config.toml')) return process.env.CASE === 'fast' ? 'service_tier = "fast"' : '';
  return read.call(this, p, ...args);
};`)
    executable('codex', `
const fs = require('node:fs'); const args = process.argv.slice(2); const mode = process.env.CASE;
if (args[0] === 'login') {
  console.log(mode === 'api' ? 'Logged in using an API key' : 'Logged in using ChatGPT');
  process.exit(mode === 'login' ? 1 : 0);
}
if (process.env.OPENAI_API_KEY || process.env.CODEX_API_KEY) process.exit(9);
if (mode === 'timeout') { setInterval(() => {}, 1000); }
else if (mode === 'limit') { console.log(JSON.stringify({type:'error', message:'usage limit reached'})); }
else if (mode === 'failure') { console.error('execution failed'); process.exitCode = 1; }
else if (mode !== 'empty') {
  if (!args.includes('model_reasoning_effort="medium"') || args.includes('--model')) process.exit(8);
  fs.writeFileSync(args[args.indexOf('--output-last-message') + 1], 'usage limit reached is merely quoted task text');
  console.log(JSON.stringify({type:'thread.started', thread_id:'fixture-session'}));
}`)
    for (const [mode, status, code] of [
      ['success', 0, undefined], ['login', 3, 'UNAVAILABLE'],
      ['api', 3, 'UNAVAILABLE'], ['fast', 3, 'UNAVAILABLE'],
      ['limit', 3, 'USAGE_LIMIT'], ['timeout', 4, 'TIMEOUT'],
      ['failure', 3, 'RUN_FAILED'], ['empty', 3, 'RUN_FAILED'],
      ['missing', 3, 'UNAVAILABLE'],
    ]) {
      if (mode === 'missing') fs.unlinkSync(path.join(root, 'codex'))
      const result = spawnSync(process.execPath, [wrapper, '--repo', root, '--prompt', '-', '--timeout', mode === 'timeout' ? '0.2' : '5'], {
        input: 'fixture prompt', encoding: 'utf8', timeout: 10000,
        env: { PATH: root, TMPDIR: root, NODE_OPTIONS: `--require=${preload}`, CASE: mode,
          OPENAI_API_KEY: 'fake-test-value', CODEX_API_KEY: 'fake-test-value' },
      })
      assert.equal(result.status, status, `${mode}: ${result.stderr}`)
      const lines = result.stdout.trim().split('\n')
      assert.equal(lines.length, 1, mode)
      const output = JSON.parse(lines[0])
      assert.equal(output.provider, 'codex', mode)
      assert.equal(output.code, code, mode)
      assert.equal(output.ok, mode === 'success', mode)
      if (mode === 'success') assert.equal(output.session, 'fixture-session')
      assert.equal(fs.existsSync(marker), false, `${mode}: API fallback invoked`)
    }
  } finally {
    fs.rmSync(root, { recursive: true, force: true })
  }
})
