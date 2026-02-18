---
title: Mobile Access via Secure Tunneling
sidebar_position: 3
sidebar_label: Mobile Access
description: Enable remote access to lyxal from mobile devices using secure tunneling.
---

import { PanelLeft } from 'lucide-react';

Mobile access lets you connect to lyxal remotely from an iOS mobile device using secure tunneling.

:::warning Experimental Feature
Mobile access is a preview feature in active development. Behavior and configuration may change in future releases.
:::

## How Mobile Access Works

Mobile access connects your iOS device to lyxal Desktop through a secure tunnel. After you install and configure the **lyxal AI** app, you can access lyxal from anywhere.

**Key details:**
- Uses [Lapstone](https://github.com/michaelneale/lapstone-tunnel), a public HTTPS tunnel service provided by Mic Neale
- Easy setup using a QR code with a unique secret key to secure the connection
- Your tunnel URL remains the same across sessions, so you only need to configure your mobile app once
- The connection requires your computer to be awake with lyxal Desktop running
- Automatically reconnects if interrupted and restarts when you launch lyxal Desktop

## Setup

### Install the App
1. Install the **lyxal AI** app on your iOS mobile device from the [App Store](https://apps.apple.com/app/lyxal-ai/id6752889295)

:::tip App Store QR Code
Follow the steps below to open the `Remote Access` section, then click "scan QR code" in the info box for quick access to the App Store.
:::

### Start the Tunnel
1. Open lyxal Desktop
2. Click the <PanelLeft className="inline" size={16} /> button in the top-left to open the sidebar
3. Click `Settings` in the sidebar
4. Click `App`
5. Scroll down to the `Remote Access` section and click `Start Tunnel`

Once the tunnel starts, you'll see a `Remote Access Connection` QR code for configuring the app.

:::info 
Click `Stop Tunnel` at any time to close the connection.
:::

### Connect the App
1. Open the **lyxal AI** app on your iOS mobile device
2. Scan the `Remote Access Connection` QR code displayed in lyxal Desktop
3. The app will automatically configure the connection

You can now access lyxal Desktop from your mobile device.

## What You Can Do

The mobile app gives you full access to lyxal:
- Start new conversations or continue existing sessions
- Use all your lyxal extensions and configurations
- Work from anywhere while your computer handles the processing

## Additional Resources

import ContentCardCarousel from '@site/src/components/ContentCardCarousel';
import mobileShots from '@site/blog/2025-12-19-lyxal-mobile-terminal/mobile_shots.png';

<ContentCardCarousel
  items={[
    {
      type: 'blog',
      title: 'lyxal Mobile Access and Native Terminal Support',
      description: 'Learn about two new ways to use lyxal: iOS app for mobile access and native terminal support with seamless session continuity.',
      thumbnailUrl: mobileShots,
      linkUrl: '/lyxal/blog/2025/12/19/lyxal-mobile-terminal',
      date: '2025-12-19',
      duration: '4 min read'
    }
  ]}
/>
