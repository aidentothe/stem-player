# Stem Player for macOS

A multi-touch stem player application for macOS that uses trackpad input to control audio playback and apply effects in real-time.

## Features

- **Multi-touch Trackpad Control**: Use your MacBook trackpad as a musical instrument
- **Real-time Audio Effects**: Apply filters, pitch shifting, and other effects through touch gestures
- **Visual Feedback**: Beautiful CSS-styled interface with real-time visualization of touch points
- **Multiple Audio Stems**: Control different audio tracks simultaneously
- **Low Latency**: Optimized for real-time audio performance

## System Requirements

- macOS 10.15 or later
- MacBook with Force Touch trackpad or Magic Trackpad 2
- Xcode Command Line Tools

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/aidentothe/stem-player.git
cd stem-player
```

2. Build the application:
```bash
make
```

3. Run the application:
```bash
./TrackpadFaderAppV3
```

### Using Pre-built App

You can also use the pre-built application bundle:
```bash
open app/TrackpadFaderApp.app
```

## Usage

### Basic Controls

- **Touch**: Press on the trackpad to activate audio playback
- **Slide**: Move your finger(s) to control various parameters
- **Multi-touch**: Use multiple fingers for different effects
- **Force Touch**: Apply pressure for additional control

### Gesture Mapping

| Gesture | Action |
|---------|---------|
| Single Touch | Play/control primary stem |
| Two Finger Touch | Control filter frequency |
| Three Finger Touch | Control reverb amount |
| Force Touch | Control volume/intensity |
| Horizontal Slide | Control pan/position |
| Vertical Slide | Control pitch/effects |

## Architecture

The application consists of several key components:

- **TrackpadFaderAppV3**: Main application controller and UI management
- **TrackpadWrapper**: Low-level trackpad input handling and gesture recognition
- **SystemCSSComponents**: Visual styling and animation system
- **Audio Engine**: Core audio processing and effects chain

## Development

### Prerequisites

- Xcode 12.0 or later
- macOS SDK 10.15+
- Git

### Project Structure

```
stem-player/
├── src/                 # Source code files
│   ├── TrackpadFaderAppV3.m
│   ├── TrackpadFaderAppV3.h
│   ├── TrackpadWrapper.m
│   ├── TrackpadWrapper.h
│   ├── SystemCSSComponents.m
│   └── SystemCSSComponents.h
├── SystemCSS/          # CSS styling resources
├── app/                # Application bundle
├── Makefile           # Build configuration
└── README.md          # This file
```

### Building for Development

```bash
# Debug build
make debug

# Release build with optimizations
make release

# Clean build artifacts
make clean
```

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Audio Format Support

The application supports various audio formats:
- WAV (recommended for best performance)
- MP3
- AAC
- AIFF
- FLAC

## Performance Optimization

For best performance:
- Use WAV files for stems
- Keep buffer size at 256 or 512 samples
- Close unnecessary applications
- Disable Bluetooth if not needed

## Troubleshooting

### Application won't start
- Ensure you have granted accessibility permissions in System Preferences > Security & Privacy > Privacy > Accessibility

### No trackpad input detected
- Check that your trackpad is properly connected
- Restart the application
- Try resetting the SMC (System Management Controller)

### Audio latency issues
- Reduce buffer size in audio settings
- Close other audio applications
- Check Activity Monitor for high CPU usage

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Apple's Core Audio and Multi-Touch frameworks
- Inspired by professional DJ controllers and music production tools
- Thanks to the macOS audio development community

## Support

For issues, questions, or suggestions, please open an issue on [GitHub](https://github.com/aidentothe/stem-player/issues).

## Roadmap

- [ ] MIDI controller support
- [ ] Recording capabilities
- [ ] Custom gesture mapping
- [ ] Plugin system for custom effects
- [ ] Windows/Linux support via cross-platform framework
- [ ] Network collaboration features

---

Made with ❤️ for the music production community