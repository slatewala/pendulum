---
title: "Pendulum - The Pure-Timing Game That Lives And Dies On One Tap"
date: 2026-04-26
categories:
  - Games
  - Mobile
tags:
  - flutter
  - physics
  - timing
  - hyper-casual
  - android
excerpt: "A ball swings on a rope. Tap to release at the right second of the arc. Land safe or fall forever."
featured_image: /assets/games/pendulum-feature.png
---

## A Single Decision, Repeated Forever

**Pendulum** removes every variable except one - when do you let go? A ball swings on a rope from a fixed anchor. Below it sits a small green platform. Tap the screen and the rope detaches. Now gravity owns the ball. Will it land safely or sail past?

Most arcade games give you a hundred chances per minute. Pendulum gives you one chance per swing. The compression of stakes is what makes it stick.

## The Physics, Visible

Behind the scenes, the ball swings under tangential acceleration projected from gravity onto the rope. After release, it follows a clean parabolic fall. Air resistance is barely there - a 0.1% velocity damp per frame to prevent infinite oscillation.

Players can read the trajectory after a few rounds because the math is honest. The platform drift, the rope length variation, and the ball starting angle are all randomized per round, but the underlying motion is predictable. Mastery feels earned.

## Why It Lives In Your Head

The cruelest part of one-tap timing is **post-action regret**. You released too early. You watched it sail past. You knew the moment your thumb hit the screen. Pendulum runs on that regret loop - one more attempt, definitely this time, no really this time.

After ten rounds the platform shrinks. After twenty it is half its original size. The game does not need a difficulty curve script. The shrinking platform is the entire curriculum.

## Built In Flutter

Pure `CustomPainter` rendering. One `Ticker` for the simulation. The whole game state is six fields and twenty lines of physics. No assets except a generated launcher icon and a single pluck sound effect synthesized at build time.

## Try It

Source, custom icon, sound effect, release APK on GitHub. Sideload, fall ten times, land once, feel something.
