# Pulse Secure Virtual Traffic Manager

## Introduction

This integration provides an Adaptable Application driver (`Pulse-Secure-vTM.ps1`) that automates TLS certificate provisioning and renewal on Pulse Secure (Ivanti) Virtual Traffic Manager from Certificate Manager, Self-Hosted.

## Installation

1. Download `Pulse-Secure-vTM.ps1` using the Download button.
2. Copy the script to the `<Venafi root directory>\Scripts\AdaptableApp\` folder on every TPP engine that will run the driver.
3. Create an Adaptable Application driver object and select `Pulse-Secure-vTM.ps1` as the PowerShell script.

## Configuration

For general configuration instructions, refer to the official Venafi product documentation for [Adaptable Application drivers](https://docs.venafi.com/Docs/current/TopNav/Content/AdaptableFrameworks/c_AdaptableApp_overview.php).
