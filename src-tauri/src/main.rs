// 简·画报 Jade Daily — Tauri 2 壳层
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use chinese_lunisolar_calendar::{LunisolarDate, SolarDate};

/// 农历信息：干支年、生肖、农历月日（`{:#}` 格式化输出简体中文）。
#[tauri::command]
fn lunar_info(year: u16, month: u8, day: u8) -> Result<serde_json::Value, String> {
    let solar = SolarDate::from_ymd(year, month, day).map_err(|e| e.to_string())?;
    let lunisolar = LunisolarDate::from_solar_date(solar).map_err(|e| e.to_string())?;
    Ok(serde_json::json!({
        "ganzhi": format!("{:#}", lunisolar.to_lunar_year()),
        "zodiac": format!("{:#}", lunisolar.to_lunisolar_year().to_zodiac()),
        "month": format!("{:#}", lunisolar.to_lunar_month()),
        "day": format!("{:#}", lunisolar.to_lunar_day()),
    }))
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_autostart::init(
            tauri_plugin_autostart::MacosLauncher::LaunchAgent,
            None,
        ))
        .invoke_handler(tauri::generate_handler![lunar_info])
        .run(tauri::generate_context!())
        .expect("简·画报启动失败");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn 春节_2026_丙午马年正月初一() {
        let info = lunar_info(2026, 2, 17).unwrap();
        assert_eq!(info["ganzhi"], "丙午");
        assert_eq!(info["zodiac"], "马");
        assert_eq!(info["month"], "正月");
        assert_eq!(info["day"], "初一");
    }

    #[test]
    fn 普通日期_2026_10_07_八月廿七() {
        let info = lunar_info(2026, 10, 7).unwrap();
        assert_eq!(info["ganzhi"], "丙午");
        assert_eq!(info["month"], "八月");
        assert_eq!(info["day"], "廿七");
    }

    #[test]
    fn 跨年_2025_乙巳蛇年() {
        let info = lunar_info(2025, 6, 23).unwrap();
        assert_eq!(info["ganzhi"], "乙巳");
        assert_eq!(info["zodiac"], "蛇");
    }

    #[test]
    fn 越界日期返回错误() {
        assert!(lunar_info(1800, 1, 1).is_err());
    }
}
