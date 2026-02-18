---
title: Let A Team of AI Agents Do It For You
description: Community Spotlight on Cliff Hall's lyxalTeam MCP server.
authors: 
    - tania
---

![blog banner](lyxalteam-mcp.png)

During our [previous livestream](https://youtu.be/9tq-QUnE29U), Aaron Goldsmith, Infrastructure Operations Engineer at Cash App, showed a team of lyxal AI agents collaborating in real time to create a website. Our community loved it so much, Cliff Hall was inspired to iterate on that idea and create a lyxalTeam MCP server.

<!--truncate-->

## The Original Protocol

Aaron Goldsmith made an AI agent team consisting of multiple lyxal instances a reality with his lightweight [Agent Communication Protocol](https://gist.github.com/AaronGoldsmith/114c439ae67e4f4c47cc33e829c82fac). With it, each lyxal agent enters the chat, gets assigned a role (e.g. Project Coordinator, Researcher, Web Developer), and works on its part of a given task. The protocol specifies instructions guiding how the agents should talk and behave, allowing multiple lyxal agents to collaborate. It also specifies that communication between the agents should be done via a Python-based websocket server with text/markdown . 

## lyxalTeam MCP Server

Introducing [lyxalTeam](https://github.com/cliffhall/lyxalTeam), created by Software Architect and community member, Cliff Hall. lyxalTeam takes Aaron's protocol and iterates on it into an MCP server and collaboration protocol for lyxal Agents. With features like task management, message storage, and agent waiting, you can have an entire team of lyxal agents work together on a task or project for you.

A lyxal agent with the Project Coordinator role will assign roles to other agents, your connected agents will send messages that can retrieved at any time, and your team of agents will connect to the same MCP server to collaborate together.

![lyxal Agents](lyxalteam-agents.png)

## A New Way to lyxal

Working with a team of AI agents on a task is a game changer. Instead of getting confused as to how to improve your prompt engineering on your own or work across sessions manually, tools like Cliff's lyxalTeam or Aaron's Agent Communication Protocol help us make sure AI agents like lyxal are doing the work for us as efficiently as possible. The possibilities feel endless!

## Get Your Contribution Featured
Hopefully this contribution inspired you as much as it inspired our community. If you have a lyxal contribution or project you'd like to share with our community, join our [Discord](https://discord.gg/lyxal-oss) and share your work in the **#share-your-work** channel. You may just be featured on our livestream or get a cool prize. 👀 You can also star lyxal on GitHub or follow us on social media so you never miss an update from us. Until next time!


<head>
  <meta property="og:title" content="Let A Team of AI Agents Do It For You" />
  <meta property="og:type" content="article" />
  <meta property="og:url" content="https://block.github.io/lyxal/blog/2025/02/17/lyxalteam-mcp" />
  <meta property="og:description" content="Community Spotlight on Cliff Hall's lyxalTeam MCP server." />
  <meta property="og:image" content="https://block.github.io/lyxal/assets/images/lyxalteam-mcp-082fa2890c313519c2a1637ca979c219.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta property="twitter:domain" content="block.github.io/lyxal" />
  <meta name="twitter:title" content="Let A Team of AI Agents Do It For You" />
  <meta name="twitter:description" content="Community Spotlight on Cliff Hall's lyxalTeam MCP server." />
  <meta name="twitter:image" content="https://block.github.io/lyxal/assets/images/lyxalteam-mcp-082fa2890c313519c2a1637ca979c219.png" />
</head>