// 跨平台模块：正常导入
pub mod logger;

pub mod tag_reader;

// Windows 平台：导入完整的实现
#[cfg(windows)]
pub mod utils;

// 导出 Windows 平台的所有功能
#[cfg(windows)]
pub use utils::*;

#[cfg(not(windows))]
pub mod utils {
    pub fn show_in_explorer(_path: String) -> bool { false }
    pub fn pick_single_folder() -> Option<String> { None }
    pub fn launch_in_browser(_uri: String) -> bool { false }
}

// 导出非 Windows 平台的空实现
#[cfg(not(windows))]
pub use utils::*;

// 导出 logger
pub use logger::*;

pub use tag_reader::*;
