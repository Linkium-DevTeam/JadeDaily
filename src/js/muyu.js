// 木鱼声：WebAudio 现场合成（760Hz 木腔共鸣 + 380Hz 低频 + 2100Hz 敲击瞬态），
// 零音频资产。首次敲击时才创建 AudioContext。

let ctx = null;

export function knock() {
  try {
    ctx ??= new (globalThis.AudioContext ?? globalThis.webkitAudioContext)();
    if (ctx.state === 'suspended') ctx.resume();
    const t = ctx.currentTime;
    for (const [freq, gain, decay] of [
      [760, 0.4, 0.18],
      [380, 0.26, 0.22],
      [2100, 0.1, 0.05],
    ]) {
      const osc = ctx.createOscillator();
      const amp = ctx.createGain();
      osc.frequency.value = freq;
      amp.gain.setValueAtTime(0.0001, t);
      amp.gain.linearRampToValueAtTime(gain, t + 0.002);
      amp.gain.exponentialRampToValueAtTime(0.0001, t + decay);
      osc.connect(amp).connect(ctx.destination);
      osc.start(t);
      osc.stop(t + decay + 0.02);
    }
  } catch {
    // 无声胜有声：音频不可用不影响功德
  }
}
