#!/bin/bash

# Leptos ShadCN UI Main Package Publishing Script
# This script publishes the main package that contains all components

set -e

echo "🚀 Publishing Leptos ShadCN UI Main Package"
echo "=============================================="

# Navigate to the main package directory
cd packages/leptos-shadcn-ui

echo "📦 Package: leptos-shadcn-ui"
echo "📋 Version: 0.9.0"
echo ""

# Check if component compiles
echo "🔍 Checking compilation..."
if cargo check --quiet; then
    echo "  ✅ Package compiles successfully"
    
    # Check with all features
    echo "  🔍 Checking with all components enabled..."
    if cargo check --features all-components --quiet; then
        echo "  ✅ All components compile successfully"
        
        # Publish to crates.io
        echo "  🚀 Publishing to crates.io..."
        if cargo publish --quiet; then
            echo "  ✅ leptos-shadcn-ui published successfully!"
            echo ""
            echo "🎉 Main package published successfully!"
            echo ""
            echo "📋 Users can now install with:"
            echo "   [dependencies]"
            echo "   leptos-shadcn-ui = \"0.9.0\""
            echo ""
            echo "🔧 And use with:"
            echo "   use lyx_ui_shadcn_ui::{Button, Input, Card};"
            echo ""
            echo "✨ Or enable specific components:"
            echo "   leptos-shadcn-ui = { version = \"0.1.0\", features = [\"button\", \"input\"] }"
        else
            echo "  ❌ Failed to publish leptos-shadcn-ui"
            exit 1
        fi
    else
        echo "  ❌ Components compilation failed"
        exit 1
    fi
else
    echo "  ❌ Package compilation failed"
    exit 1
fi

echo ""
echo "✅ Main package release complete!"
