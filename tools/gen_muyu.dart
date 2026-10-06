// 合成木鱼敲击声：基频 760Hz 木腔共鸣 + 低频 380Hz + 高频敲击瞬态，
// 指数衰减，输出 16-bit PCM 单声道 WAV 到 assets/sounds/muyu.wav。
//
// 运行：dart run tools/gen_muyu.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main(List<String> args) {
  final out = args.isNotEmpty ? args[0] : 'assets/sounds/muyu.wav';
  const sampleRate = 44100;
  const durationSec = 0.22;
  final total = (sampleRate * durationSec).round();

  final samples = Float32List(total);
  var peak = 0.0;
  for (var i = 0; i < total; i++) {
    final t = i / sampleRate;
    var v = 0.0;
    v += 0.55 * math.sin(2 * math.pi * 760 * t) * math.exp(-18 * t);
    v += 0.35 * math.sin(2 * math.pi * 380 * t) * math.exp(-14 * t);
    v += 0.15 * math.sin(2 * math.pi * 2100 * t) * math.exp(-60 * t);
    // 2ms 起音包络，避免爆音
    final attack = (t / 0.002).clamp(0.0, 1.0);
    samples[i] = v * attack;
    final abs = samples[i].abs();
    if (abs > peak) peak = abs;
  }

  final data = ByteData(total * 2);
  for (var i = 0; i < total; i++) {
    final s = (samples[i] / peak * 0.82 * 32767).round();
    data.setInt16(i * 2, s, Endian.little);
  }

  final wav = BytesBuilder();
  _ascii(wav, 'RIFF');
  _u32(wav, 36 + data.lengthInBytes);
  _ascii(wav, 'WAVE');
  _ascii(wav, 'fmt ');
  _u32(wav, 16); // PCM fmt chunk size
  _u16(wav, 1); // PCM
  _u16(wav, 1); // mono
  _u32(wav, sampleRate);
  _u32(wav, sampleRate * 2); // byte rate
  _u16(wav, 2); // block align
  _u16(wav, 16); // bits per sample
  _ascii(wav, 'data');
  _u32(wav, data.lengthInBytes);
  wav.add(data.buffer.asUint8List());

  final file = File(out);
  file.createSync(recursive: true);
  file.writeAsBytesSync(wav.toBytes(), flush: true);
  stdout.writeln('Wrote $out (${file.lengthSync()} bytes)');
}

void _ascii(BytesBuilder b, String s) => b.add(s.codeUnits);
void _u16(BytesBuilder b, int v) => b.add([
      v & 0xFF,
      (v >> 8) & 0xFF,
    ]);
void _u32(BytesBuilder b, int v) => b.add([
      v & 0xFF,
      (v >> 8) & 0xFF,
      (v >> 16) & 0xFF,
      (v >> 24) & 0xFF,
    ]);
