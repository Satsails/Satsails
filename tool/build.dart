// tool/build.dart
import 'dart:io';

/// Path to the main SVG logo.
const svgPath = 'lib/assets/satsails.svg';

/// The directory for all generated asset files.
const generatedAssetsDir = 'lib/assets';

Future<void> main() async {
  print('🚀 Generating splash screen asset...');
  await Directory(generatedAssetsDir).create(recursive: true);
  await _generateSplashAssets();
  print('\n✅ Splash screen generated successfully!');
}

/// Generates a white version of the SVG for the splash screen.
Future<void> _generateSplashAssets() async {
  print('🎨 Creating white PNG from SVG...');
  await _createWhiteVariant(
    inputSvgPath: svgPath,
    outputPngPath: '$generatedAssetsDir/splash_white.png',
    size: 1024,
  );
  print('🏃 Running flutter_native_splash...');
  await _run(
    'flutter',
    ['pub', 'run', 'flutter_native_splash:create'],
  );
}

// --- Helper Functions ---

/// Creates a white PNG variant from a given SVG.
Future<void> _createWhiteVariant({
  required String inputSvgPath,
  required String outputPngPath,
  required int size,
}) async {
  final tempSvgFile = File('$generatedAssetsDir/temp_white.svg');
  final svgContent = await File(inputSvgPath).readAsString();
  final whiteSvgContent = svgContent.replaceAll(RegExp(r'fill="[^"]+"'), 'fill="#FFFFFF"');
  await tempSvgFile.writeAsString(whiteSvgContent);
  await _svgToPng(
    inputSvgPath: tempSvgFile.path,
    outputPngPath: outputPngPath,
    size: size,
  );
  await tempSvgFile.delete();
}

/// Converts an SVG file to a PNG file using ImageMagick.
Future<void> _svgToPng({
  required String inputSvgPath,
  required String outputPngPath,
  required int size,
}) async {
  // **THE FIX IS HERE**
  // We reduce the size of the icon to 1/2 of the canvas for more padding.
  final safeZoneSize = (size * 1 / 2).round();

  await _run('magick', [
    // 1. Render the SVG at high density for crisp quality.
    '-density', '400',
    '-background', 'none',
    inputSvgPath,

    // 2. Resize the icon down to the new, smaller 'safe zone'.
    '-resize', '${safeZoneSize}x$safeZoneSize',

    // 3. Center the smaller icon on a new, larger transparent canvas.
    '-gravity', 'center',
    '-extent', '${size}x$size', // Extends the canvas to the original size, adding padding.

    // 4. Write the final, padded image file.
    outputPngPath,
  ]);
}

/// A robust utility to run shell commands.
Future<void> _run(String cmd, List<String> args) async {
  final result = await Process.run(cmd, args);
  if (result.exitCode != 0) {
    stderr.writeln('Error: Command failed: $cmd ${args.join(" ")}');
    stderr.writeln(result.stderr);
    throw Exception('Command execution failed.');
  }
  if (result.stdout.toString().trim().isNotEmpty) {
    print(result.stdout);
  }
}