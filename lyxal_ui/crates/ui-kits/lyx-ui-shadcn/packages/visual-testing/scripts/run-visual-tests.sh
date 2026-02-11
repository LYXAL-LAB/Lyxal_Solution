#!/bin/bash
# Visual regression testing script for CI/CD
# This script runs visual tests and generates reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$(dirname "$PACKAGE_DIR")")"

cd "$PACKAGE_DIR"

echo -e "${GREEN}🎨 Visual Regression Testing${NC}"
echo "========================================"

# Parse arguments
UPDATE_SNAPSHOTS=false
HEADED=false
DEBUG=false
COMPONENT=""
REPORT_DIR="test-results"

while [[ $# -gt 0 ]]; do
  case $1 in
    --update)
      UPDATE_SNAPSHOTS=true
      shift
      ;;
    --headed)
      HEADED=true
      shift
      ;;
    --debug)
      DEBUG=true
      shift
      ;;
    --component)
      COMPONENT="$2"
      shift 2
      ;;
    --report-dir)
      REPORT_DIR="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --update         Update snapshots instead of comparing"
      echo "  --headed         Run tests in headed mode (show browser)"
      echo "  --debug          Run tests in debug mode"
      echo "  --component NAME Run tests for specific component only"
      echo "  --report-dir DIR Output directory for test reports"
      echo "  --help           Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}Installing dependencies...${NC}"
  npm install
fi

# Check if Playwright browsers are installed
if ! npx playwright --version &> /dev/null; then
  echo -e "${YELLOW}Installing Playwright browsers...${NC}"
  npx playwright install --with-deps chromium firefox webkit
fi

# Build the command
CMD="npx playwright test"

if [ "$UPDATE_SNAPSHOTS" = true ]; then
  echo -e "${YELLOW}📸 Updating snapshots...${NC}"
  CMD="$CMD --update-snapshots"
fi

if [ "$HEADED" = true ]; then
  CMD="$CMD --headed"
fi

if [ "$DEBUG" = true ]; then
  CMD="$CMD --debug"
fi

if [ -n "$COMPONENT" ]; then
  echo -e "${YELLOW}Testing component: $COMPONENT${NC}"
  CMD="$CMD tests/$COMPONENT.visual.spec.ts"
fi

# Run the tests
echo -e "${GREEN}Running visual tests...${NC}"
echo "Command: $CMD"
echo ""

set +e
eval $CMD
TEST_EXIT_CODE=$?
set -e

# Generate report
echo ""
echo -e "${GREEN}📊 Generating test report...${NC}"

if [ -d "playwright-report" ]; then
  echo "Report available at: playwright-report/index.html"
fi

# Copy results to report directory if specified
if [ -n "$REPORT_DIR" ] && [ "$REPORT_DIR" != "test-results" ]; then
  mkdir -p "$PROJECT_ROOT/$REPORT_DIR"
  cp -r test-results/* "$PROJECT_ROOT/$REPORT_DIR/" 2>/dev/null || true
  cp -r playwright-report/* "$PROJECT_ROOT/$REPORT_DIR/" 2>/dev/null || true
fi

# Exit with appropriate code
if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}✅ All visual tests passed!${NC}"
else
  echo -e "${RED}❌ Visual tests failed!${NC}"
  echo "Check the report for details."
fi

exit $TEST_EXIT_CODE
