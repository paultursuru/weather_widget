# xbar MeteoSuisse Plugin 🇨🇭

A clean, data-rich weather plugin for [xbar](https://github.com/matryer/xbar) (the BitBar successor) written in Ruby. It fetches real-time, high-precision data from **MeteoSuisse** for Swiss locations.

## Features

* **Menu Bar Glance**: Displays the current temperature directly in your macOS menu bar.
* **Dynamic Icons**: Fetches official MeteoSuisse SVG symbols and converts them to **Base64** on the fly for seamless display without local assets.
* **Detailed Forecast**:
    * **Current Conditions**: Temperature, rainfall, wind speed, wind direction, and gusts.
    * **Next Hour**: A dedicated "short-term" forecast to see what's coming immediately.
    * **Weekly Outlook**: A 7-day forecast including daily icons and temperature ranges.
* **Direct Links**: Click any item to open the detailed forecast on the MeteoSuisse website.

## Installation

1.  **Requirement**: Ensure you have [xbar](https://github.com/matryer/xbar) installed and Ruby available on your system.
2.  **Clone the repository**: 
    * *Tip: The `.10m` in the filename tells xbar to refresh the data every 10 minutes. You can change it to `.1h` to refresh every hour.*
3.  **Make it Executable**:
    ```bash
    chmod +x ~/Library/Application\ Support/xbar/plugins/weather.10m.rb
    ```
4.  **Move it to the plugins folder**:
    Something like this:
    ```bash
    mv weather.10m.rb ~/Library/Application\ Support/xbar/plugins/weather.10m.rb
    ```
5.  **Refresh xbar**: Select "Refresh all" from the xbar menu.

## Configuration

By default, the script is configured for **Lausanne (1007)**. To change the location, set the `VAR_POSTAL_CODE` xbar variable to any Swiss postal code:

* from xbar: open the plugin browser (**xbar → Open plugin…**), select the weather plugin and edit the variable, or
* by hand: create `weather.10m.rb.vars.json` next to the plugin with `{"VAR_POSTAL_CODE": "1201"}`.

The city name, the MeteoSuisse link and the forecast location are looked up from the postal code. When several localities share a postal code, the main one is used.

## Technical Details

| Category | Description |
| :--- | :--- |
| **Language** | Ruby |
| **Data Source** | MeteoSuisse (admin.ch) |
| **Dependencies** | `json`, `open-uri`, `base64`, `date` (Standard Libraries) |
| **Rendering** | Base64 encoded SVGs |

---

## Author

* [@paultursuru](https://github.com/paultursuru)

---
*Disclaimer: This plugin is for fun and not officially affiliated with MeteoSuisse.*