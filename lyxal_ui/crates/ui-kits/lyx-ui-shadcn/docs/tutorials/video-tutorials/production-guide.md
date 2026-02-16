# Video Production Guide

This guide provides standards and best practices for creating video tutorials for the leptos-shadcn-ui project.

## Production Standards

### Technical Requirements

| Aspect | Requirement |
|--------|-------------|
| **Resolution** | Minimum 1920x1080 (1080p), preferred 4K |
| **Frame Rate** | 30fps or 60fps |
| **Aspect Ratio** | 16:9 landscape |
| **Audio Quality** | Clear voice, minimum 48kHz, no background noise |
| **Format** | MP4 (H.264) or WebM |
| **Bitrate** | 8-16 Mbps (1080p), 20-40 Mbps (4K) |
| **Duration** | Focused content: 10-30 minutes per video |

### Content Structure

Each tutorial should follow this structure:

1. **Introduction (30-60 seconds)**
   - Brief overview of what will be covered
   - Prerequisites check
   - Expected learning outcomes

2. **Main Content (70-80% of video)**
   - Step-by-step demonstrations
   - Clear explanations of concepts
   - Real-time coding examples
   - Common pitfalls and solutions

3. **Summary (1-2 minutes)**
   - Recap of key points
   - Next steps recommendations
   - Resources for further learning

## Recording Setup

### Recommended Hardware

**Video Recording:**
- Camera: DSLR, Mirrorless, or high-quality webcam
- Microphone: Dedicated USB or XLR microphone
- Lighting: Softbox or ring light for face (if visible)
- Screen: 1080p monitor minimum

**Audio Setup:**
- Primary: Shure SM7B, Blue Yeti, or similar quality microphone
- Backup: High-quality headset microphone
- Pop filter: Essential for plosive sounds
- Acoustic treatment: Reduce echo and reverb

### Recommended Software

**Screen Recording:**
- **OBS Studio** (Free, cross-platform) - Recommended
- **Camtasia** (Paid) - Built-in editing
- **QuickTime Player** (macOS) - Basic recording
- **Kazam** (Linux) - Simple screen recorder

**Video Editing:**
- **DaVinci Resolve** (Free) - Professional editing
- **Final Cut Pro** (macOS) - Intermediate to advanced
- **Adobe Premiere Pro** (Paid) - Industry standard
- **Kdenlive** (Free, cross-platform) - Open source

**Audio Editing:**
- **Audacity** (Free) - Basic audio cleanup
- **Adobe Audition** (Paid) - Professional audio editing
- **GarageBand** (macOS) - Basic audio work

### Recording Configuration

**OBS Studio Settings:**

```
Video:
  - Base Resolution: 1920x1080
  - Output Resolution: 1920x1080
  - FPS: 30 or 60
  - Downscale Filter: Lanczos

Audio:
  - Sample Rate: 48 kHz
  - Channels: Stereo
  - Mic/Auxiliary Audio: Default

Output (Recording):
  - Format: MP4
  - Video Encoder: x264
  - Rate Control: CBR
  - Bitrate: 2500-6000 Kbps
  - Audio Encoder: AAC
  - Audio Bitrate: 192-320 Kbps
```

## Production Checklist

### Pre-Recording

- [ ] Script completed and reviewed
- [ ] Code examples tested and working
- [ ] Development environment prepared
- [ ] Sample project ready for demonstration
- [ ] Microphone tested and positioned
- [ ] Recording software configured
- [ ] Screen resolution set to 1080p minimum
- [ ] Notifications disabled
- [ ] Clean desktop (close unnecessary apps)

### During Recording

- [ ] Speak clearly and at moderate pace
- [ ] Use consistent terminology
- [ ] Announce keyboard shortcuts when using them
- [ ] Pause briefly after important points
- [ ] Explain "why" not just "how"
- [ ] Include common mistakes and fixes
- [ ] Maintain consistent microphone distance
- [ ] Keep mouse movements smooth and deliberate

### Post-Recording

- [ ] Audio cleanup (remove noise, clicks)
- [ ] Normalize audio levels
- [ ] Add intro/outro screens
- [ ] Insert lower-thirds for key concepts
- [ ] Highlight important code sections
- [ ] Add captions/transcript
- [ ] Export in correct format
- [ ] Test playback on multiple devices

## Visual Standards

### Screen Recording Tips

1. **Font Size**: Increase editor font to 14-16pt minimum
2. **Color Scheme**: Use high-contrast theme (e.g., GitHub Dark, Nord)
3. **Window Size**: Keep editor at full screen or consistent 2/3 width
4. **Cursor**: Use visible cursor with click indicators
5. **Terminal**: High contrast, large font, avoid scrolling when possible

### Branding Elements

- **Intro**: 5-10 second branded intro animation
- **Lower Thirds**: Use consistent style for speaker/concept titles
- **Progress Indicators**: Show tutorial progress
- **Code Highlighting**: Consistent color scheme for syntax highlighting
- **Theme Colors**: Use leptos-shadcn-ui brand colors in overlays

## Script Template

```markdown
# [Tutorial Title]

## Metadata
- **Series**: [Getting Started/Component/Advanced]
- **Difficulty**: [Beginner/Intermediate/Advanced]
- **Duration**: [Estimated minutes]
- **Prerequisites**: [List]
- **Learning Objectives**: [List]

## Outline with Timestamps

**[0:00]** Introduction
- Hook: Why this topic matters
- What we'll build
- Prerequisites check

**[X:XX]** Section 1 Title
- Key concept explanation
- Code demonstration
- Common pitfalls

**[X:XX]** Section 2 Title
...

**[X:XX]** Summary
- Recap of key points
- Next steps
- Additional resources

## Script Content

[Detailed script with:]
- Spoken dialogue
- Code examples
- Visual cues (zoom, highlight, etc.)
- Keyboard shortcuts to announce
- Pauses for emphasis

## Post-Production Notes

[Sections requiring:]
- Visual overlays
- Diagrams/illustrations
- B-roll footage
- Screen recordings
- External resources
```

## Code Examples Standards

### Live Coding Guidelines

1. **Preparation**: Have code ready, but explain as you type
2. **Typing**: Type at reasonable pace, explain each section
3. **Mistakes**: Include common errors and how to fix them
4. **Testing**: Always run code after writing it
5. **Refactoring**: Show iterative improvements

### Code Display

```rust
// Always include comments explaining what we're doing
// Use clear variable names

#[component]
pub fn Example() -> impl IntoView {
    // Explain what this signal does
    let (count, set_count) = create_signal(0);

    view! {
        // Describe the view structure
        <div>
            {count}
        </div>
    }
}
```

## Accessibility

### Captions and Transcripts

- **Captions**: Required for all videos
- **Format**: SRT or VTT files
- **Timing**: Sync with spoken audio
- **Content**: Include sound descriptions [music], [applause]
- **Transcripts**: Provide full text transcript in documentation

### Visual Accessibility

- **Color Contrast**: Minimum 4.5:1 for text
- **Font Size**: Large enough to be readable
- **Visual Cues**: Don't rely solely on color
- **Pacing**: Allow time for information processing

## Hosting and Distribution

### Platform Guidelines

**YouTube:**
- Upload as unlisted or public
- Add chapter markers (timestamps)
- Include detailed description
- Add closed captions
- Create playlist for series

**Self-Hosted:**
- Use video.js or similar player
- Provide multiple quality options
- Enable captions selection
- Include download option for offline viewing

### File Organization

```
/docs/tutorials/video-assets/
├── getting-started/
│   ├── 01-installation/
│   │   ├── video.mp4
│   │   ├── video.srt
│   │   ├── thumbnail.png
│   │   └── transcript.md
│   ├── 02-first-component/
│   └── ...
├── components/
└── advanced/

/shared/
├── intro-animation.mp4
├── outro-animation.mp4
├── lower-thirds/
└── sound-effects/
```

## Quality Assurance

### Review Process

1. **Self-Review**: Watch entire video, note improvements
2. **Peer Review**: Have team member review for clarity
3. **Technical Review**: Verify code examples work
4. **Accessibility Review**: Check captions and visual clarity

### Common Issues to Check

- [ ] Audio is clear and consistent
- [ ] Screen is clearly visible
- [ ] No distracting background noise
- [ ] Explanations are clear and concise
- [ ] Code is error-free
- [ ] Pacing is appropriate
- [ ] Captions are accurate
- [ ] Links and resources are current

## Contributing Tutorials

### Submitting a Tutorial

1. **Proposal**: Open issue with tutorial idea
2. **Approval**: Get approval from maintainers
3. **Production**: Follow this guide
4. **Review**: Submit for review
5. **Publish**: Merge with appropriate credit

### Credit and Attribution

All contributors will be credited in:
- Video description
- Tutorial documentation
- Contributors section

## Resources

### Recording Tutorials
- [OBS Studio Documentation](https://obsproject.com/wiki)
- [DaVinci Resolve Tutorial Series](https://www.blackmagicdesign.com/products/davinciresolve/training)
- [Audio Recording Guide](https://www.transom.org/2015/basics-of-recording-great-audio/)

### Learning Resources
- [Video Script Writing](https://www.techsmith.com/blog/how-to-write-a-video-script/)
- [Screencast Best Practices](https://www.oreilly.com/library/view/screencast-fundamentals/9780133581391/)
- [Educational Video Production](https://www.coursera.org/learn/learning-to-teach-online)

### Audio Resources
- [Audacity Manual](https://manual.audacityteam.org/)
- [Podcast Advice](https://www.transom.org/)

## Support

For questions about video production:
- Open an issue in the repository
- Contact the documentation team
- Join the community Discord

---

**Remember**: The goal is to create clear, helpful tutorials that enable developers to effectively use leptos-shadcn-ui components. Focus on clarity over production perfection - good content is more important than perfect cinematography.
