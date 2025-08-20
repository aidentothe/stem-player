# Makefile for SystemCSS Component Library Demo
# Builds the demonstration application showcasing all SystemCSS components

# Compiler and flags
CC = clang
CFLAGS = -Wall -Wextra -std=c11 -fobjc-arc
OBJCFLAGS = -framework Cocoa -framework QuartzCore

# Directories
SRC_DIR = .
COMPONENTS_DIR = Components
DEMO_DIR = Demo
BUILD_DIR = build

# Target
TARGET = SystemCSSDemo
APP_NAME = SystemCSSDemo.app

# Source files
COMPONENTS_SOURCES = \
	$(COMPONENTS_DIR)/SystemCSSColors.m \
	$(COMPONENTS_DIR)/SystemButton.m \
	$(COMPONENTS_DIR)/SystemWindow.m \
	$(COMPONENTS_DIR)/SystemFormComponents.m \
	$(COMPONENTS_DIR)/SystemMenu.m \
	$(COMPONENTS_DIR)/SystemDialog.m \
	SystemCSSComponents.m

DEMO_SOURCES = \
	$(DEMO_DIR)/SystemCSSDemo.m

ALL_SOURCES = $(COMPONENTS_SOURCES) $(DEMO_SOURCES)

# Object files
COMPONENTS_OBJECTS = $(COMPONENTS_SOURCES:%.m=$(BUILD_DIR)/%.o)
DEMO_OBJECTS = $(DEMO_SOURCES:%.m=$(BUILD_DIR)/%.o)
ALL_OBJECTS = $(COMPONENTS_OBJECTS) $(DEMO_OBJECTS)

# Header dependencies
HEADERS = \
	$(COMPONENTS_DIR)/SystemCSSColors.h \
	$(COMPONENTS_DIR)/SystemButton.h \
	$(COMPONENTS_DIR)/SystemWindow.h \
	$(COMPONENTS_DIR)/SystemFormComponents.h \
	$(COMPONENTS_DIR)/SystemMenu.h \
	$(COMPONENTS_DIR)/SystemDialog.h \
	SystemCSSComponents.h

# Default target
all: $(TARGET)

# Create app bundle
app: $(TARGET)
	@echo "Creating application bundle..."
	@mkdir -p $(BUILD_DIR)/$(APP_NAME)/Contents/MacOS
	@mkdir -p $(BUILD_DIR)/$(APP_NAME)/Contents/Resources
	@cp $(BUILD_DIR)/$(TARGET) $(BUILD_DIR)/$(APP_NAME)/Contents/MacOS/
	@echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "<plist version=\"1.0\">" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "<dict>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<key>CFBundleExecutable</key>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<string>$(TARGET)</string>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<key>CFBundleIdentifier</key>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<string>com.systemcss.demo</string>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<key>CFBundleName</key>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<string>SystemCSS Demo</string>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<key>CFBundleVersion</key>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<string>1.0</string>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<key>CFBundleShortVersionString</key>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<string>1.0</string>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<key>LSMinimumSystemVersion</key>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<string>10.12</string>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<key>NSHighResolutionCapable</key>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "	<string>YES</string>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "</dict>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "</plist>" >> $(BUILD_DIR)/$(APP_NAME)/Contents/Info.plist
	@echo "Application bundle created: $(BUILD_DIR)/$(APP_NAME)"

# Link target
$(TARGET): $(ALL_OBJECTS) | $(BUILD_DIR)
	@echo "Linking $(TARGET)..."
	$(CC) $(ALL_OBJECTS) $(OBJCFLAGS) -o $(BUILD_DIR)/$(TARGET)
	@echo "Build complete: $(BUILD_DIR)/$(TARGET)"

# Compile component object files
$(BUILD_DIR)/$(COMPONENTS_DIR)/%.o: $(COMPONENTS_DIR)/%.m $(HEADERS) | $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/$(COMPONENTS_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) $(OBJCFLAGS) -I$(SRC_DIR) -c $< -o $@

# Compile main library object file
$(BUILD_DIR)/%.o: %.m $(HEADERS) | $(BUILD_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) $(OBJCFLAGS) -I$(SRC_DIR) -c $< -o $@

# Compile demo object files
$(BUILD_DIR)/$(DEMO_DIR)/%.o: $(DEMO_DIR)/%.m $(HEADERS) | $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/$(DEMO_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) $(OBJCFLAGS) -I$(SRC_DIR) -c $< -o $@

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Run the demo
run: $(TARGET)
	@echo "Running SystemCSS Demo..."
	@$(BUILD_DIR)/$(TARGET)

# Run the app bundle
run-app: app
	@echo "Running SystemCSS Demo app bundle..."
	@open $(BUILD_DIR)/$(APP_NAME)

# Clean build files
clean:
	@echo "Cleaning build files..."
	@rm -rf $(BUILD_DIR)

# Clean and rebuild
rebuild: clean all

# Install system-wide (optional)
install: app
	@echo "Installing SystemCSS Demo to /Applications..."
	@sudo cp -R $(BUILD_DIR)/$(APP_NAME) /Applications/
	@echo "Installed to /Applications/$(APP_NAME)"

# Uninstall
uninstall:
	@echo "Removing SystemCSS Demo from /Applications..."
	@sudo rm -rf /Applications/$(APP_NAME)

# Development: watch for changes and rebuild
watch:
	@echo "Watching for changes... (Press Ctrl+C to stop)"
	@while true; do \
		find . -name "*.m" -o -name "*.h" | entr -d make run; \
	done

# Help
help:
	@echo "SystemCSS Component Library Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Build the demo application (default)"
	@echo "  app          - Create application bundle"
	@echo "  run          - Build and run the demo"
	@echo "  run-app      - Build app bundle and run it"
	@echo "  clean        - Remove build files"
	@echo "  rebuild      - Clean and rebuild"
	@echo "  install      - Install app to /Applications (requires sudo)"
	@echo "  uninstall    - Remove app from /Applications (requires sudo)"
	@echo "  watch        - Watch for changes and rebuild (requires entr)"
	@echo "  help         - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make         - Build the demo"
	@echo "  make run     - Build and run the demo"
	@echo "  make app     - Create app bundle"
	@echo "  make clean   - Clean build files"

# Debug information
debug-info:
	@echo "SystemCSS Build Configuration:"
	@echo "  Compiler: $(CC)"
	@echo "  Flags: $(CFLAGS) $(OBJCFLAGS)"
	@echo "  Target: $(TARGET)"
	@echo "  Build Dir: $(BUILD_DIR)"
	@echo "  Sources: $(words $(ALL_SOURCES)) files"
	@echo "  Headers: $(words $(HEADERS)) files"

# Check dependencies
check-deps:
	@echo "Checking dependencies..."
	@which clang > /dev/null || (echo "ERROR: clang not found" && exit 1)
	@echo "✓ clang found"
	@echo "All dependencies satisfied"

.PHONY: all app run run-app clean rebuild install uninstall watch help debug-info check-deps