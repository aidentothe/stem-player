# Stem Player Makefile
# Build configuration for TrackpadFaderAppV3

# Compiler and flags
CC = clang
OBJC = clang
CFLAGS = -Wall -Wextra -O2 -fobjc-arc
FRAMEWORKS = -framework Cocoa -framework AppKit -framework CoreGraphics -framework AVFoundation -framework CoreAudio -framework AudioToolbox -framework IOKit -framework QuartzCore

# Directories
SRC_DIR = src
BUILD_DIR = build
APP_NAME = TrackpadFaderAppV3
APP_BUNDLE = $(APP_NAME).app

# Source files
SOURCES = $(SRC_DIR)/TrackpadFaderAppV3.m \
          $(SRC_DIR)/TrackpadWrapper.m \
          $(SRC_DIR)/SystemCSSComponents.m

HEADERS = $(SRC_DIR)/TrackpadFaderAppV3.h \
          $(SRC_DIR)/TrackpadWrapper.h \
          $(SRC_DIR)/SystemCSSComponents.h

OBJECTS = $(SOURCES:$(SRC_DIR)/%.m=$(BUILD_DIR)/%.o)

# Targets
.PHONY: all clean debug release run app-bundle

all: release

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Build object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.m $(HEADERS) | $(BUILD_DIR)
	@echo "Compiling $<..."
	@$(OBJC) $(CFLAGS) -c $< -o $@ $(FRAMEWORKS)

# Build executable
$(APP_NAME): $(OBJECTS)
	@echo "Linking $(APP_NAME)..."
	@$(OBJC) $(CFLAGS) $(OBJECTS) -o $(APP_NAME) $(FRAMEWORKS)
	@echo "Build complete: $(APP_NAME)"

# Debug build
debug: CFLAGS = -Wall -Wextra -g -O0 -fobjc-arc -DDEBUG
debug: $(APP_NAME)

# Release build
release: CFLAGS = -Wall -Wextra -O3 -fobjc-arc -DNDEBUG
release: $(APP_NAME)

# Create app bundle
app-bundle: $(APP_NAME)
	@echo "Creating application bundle..."
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@cp $(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	@cp Info.plist $(APP_BUNDLE)/Contents/ 2>/dev/null || echo "Info.plist not found, using default"
	@echo "Application bundle created: $(APP_BUNDLE)"

# Run the application
run: $(APP_NAME)
	@echo "Running $(APP_NAME)..."
	@./$(APP_NAME)

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -f $(APP_NAME)
	@rm -rf $(APP_BUNDLE)
	@echo "Clean complete"

# Install (copies to /Applications)
install: app-bundle
	@echo "Installing to /Applications..."
	@cp -r $(APP_BUNDLE) /Applications/
	@echo "Installation complete"

# Uninstall
uninstall:
	@echo "Uninstalling from /Applications..."
	@rm -rf /Applications/$(APP_BUNDLE)
	@echo "Uninstallation complete"

# Help
help:
	@echo "Stem Player Build System"
	@echo "========================"
	@echo "Available targets:"
	@echo "  make          - Build release version"
	@echo "  make debug    - Build debug version with symbols"
	@echo "  make release  - Build optimized release version"
	@echo "  make run      - Build and run the application"
	@echo "  make app-bundle - Create macOS application bundle"
	@echo "  make clean    - Remove all build artifacts"
	@echo "  make install  - Install to /Applications"
	@echo "  make uninstall - Remove from /Applications"
	@echo "  make help     - Show this help message"