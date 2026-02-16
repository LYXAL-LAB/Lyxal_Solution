#!/bin/bash
set -e

# WASM Optimization Build Script
# This script builds WASM with maximum size optimizations to achieve <2MB bundle size

echo "🚀 Building WASM with size optimizations..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if wasm-opt is available (part of binaryen)
if command -v wasm-opt &> /dev/null; then
    echo -e "${GREEN}✅ wasm-opt found - will apply additional optimizations${NC}"
    HAS_WASM_OPT=true
else
    echo -e "${YELLOW}⚠️  wasm-opt not found. Install binaryen for additional size reduction:${NC}"
    echo "   Ubuntu/Debian: sudo apt-get install binaryen"
    echo "   macOS: brew install binaryen"
    HAS_WASM_OPT=false
fi

# Function to format bytes
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    else
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1048576}")MB"
    fi
}

# Function to get file size
get_size() {
    if [ -f "$1" ]; then
        stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Build directory
BUILD_DIR="target/wasm32-unknown-unknown/wasm-release"
WASM_FILE="${BUILD_DIR}/leptos_shadcn_ui_wasm.wasm"
WASM_FILE_OPT="${BUILD_DIR}/leptos_shadcn_ui_wasm_opt.wasm"

# Clean previous builds
echo -e "\n${YELLOW}🧹 Cleaning previous builds...${NC}"
cargo clean -p leptos-shadcn-ui-wasm

# Build with wasm-release profile
echo -e "\n${YELLOW}🔨 Building WASM with wasm-release profile...${NC}"
cargo build --profile wasm-release --target wasm32-unknown-unknown -p leptos-shadcn-ui-wasm

# Check if WASM file was created
if [ ! -f "$WASM_FILE" ]; then
    echo -e "${RED}❌ WASM file not found at $WASM_FILE${NC}"
    exit 1
fi

# Get initial size
INITIAL_SIZE=$(get_size "$WASM_FILE")
echo -e "\n${GREEN}📦 Initial WASM size: $(format_bytes $INITIAL_SIZE)${NC}"

# Target size
TARGET_SIZE=2097152  # 2MB in bytes
FINAL_WASM="$WASM_FILE"

# Apply wasm-opt optimizations if available
if [ "$HAS_WASM_OPT" = true ]; then
    echo -e "\n${YELLOW}🔧 Running wasm-opt optimizations...${NC}"
    wasm-opt --enable-bulk-memory -Oz -o "$WASM_FILE_OPT" "$WASM_FILE"

    OPTIMIZED_SIZE=$(get_size "$WASM_FILE_OPT")
    SAVED=$((INITIAL_SIZE - OPTIMIZED_SIZE))
    PERCENT=$((SAVED * 100 / INITIAL_SIZE))

    echo -e "${GREEN}✅ Optimized size: $(format_bytes $OPTIMIZED_SIZE) (saved $(format_bytes $SAVED), ${PERCENT}%)${NC}"

    # Use optimized version
    FINAL_WASM="$WASM_FILE_OPT"
    FINAL_SIZE=$OPTIMIZED_SIZE

    # Replace original with optimized
    mv "$WASM_FILE_OPT" "$WASM_FILE"
else
    FINAL_SIZE=$INITIAL_SIZE
fi

# Final size check
echo -e "\n${GREEN}📊 Final WASM bundle size: $(format_bytes $FINAL_SIZE)${NC}"
echo -e "   Location: $WASM_FILE"

if [ $FINAL_SIZE -le $TARGET_SIZE ]; then
    UNDER=$((TARGET_SIZE - FINAL_SIZE))
    PERCENT_UNDER=$((UNDER * 100 / TARGET_SIZE))
    echo -e "${GREEN}✅ SUCCESS: WASM bundle is under 2MB by $(format_bytes $UNDER) (${PERCENT_UNDER}% margin)!${NC}"
    exit 0
else
    OVER=$((FINAL_SIZE - TARGET_SIZE))
    PERCENT_OVER=$((OVER * 100 / TARGET_SIZE))
    echo -e "${RED}❌ FAILED: WASM bundle is $(format_bytes $OVER) (${PERCENT_OVER}%) over 2MB limit${NC}"
    echo -e "\n${YELLOW}Suggestions to reduce size further:${NC}"
    echo "1. Remove unused dependencies"
    echo "2. Use feature flags to disable unused components"
    echo "3. Build with only required components (not all-components feature)"
    echo "4. Consider code splitting/loading"
    exit 1
fi
