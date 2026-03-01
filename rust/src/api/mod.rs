// 跨平台模块：正常导入
pub mod logger;

pub mod tag_reader;

// Windows 平台：导入完整的实现
#[cfg(windows)]
pub mod smtc_flutter;

#[cfg(windows)]
pub mod utils;

// 导出 Windows 平台的所有功能
#[cfg(windows)]
pub use smtc_flutter::*;
#[cfg(windows)]
pub use utils::*;

// 非 Windows 平台：所有功能提供空实现
#[cfg(not(windows))]
pub mod smtc_flutter {
    use crate::frb_generated::StreamSink;

    #[derive(Clone, Copy, Debug)]
    pub enum SMTCState {
        Paused,
        Playing,
    }

    #[derive(Clone, Copy, Debug)]
    pub enum SMTCControlEvent {
        Play,
        Pause,
        Previous,
        Next,
        Unknown,
    }

    pub struct SMTCFlutter;

    impl SMTCFlutter {
        #[inline]
        pub fn new() -> Self {
            Self
        }

        pub fn subscribe_to_control_events(&self, _sink: StreamSink<SMTCControlEvent>) {}
        pub fn update_state(&self, _state: SMTCState) {}
        pub fn update_time_properties(&self, _progress: u32) {}
        pub fn update_display(&self, _title: String, _artist: String, _album: String, _duration: u32, _path: String) {}
        pub fn close(self) {}
    }
}

#[cfg(not(windows))]
pub mod utils {
    pub fn show_in_explorer(_path: String) -> bool { false }
    pub fn pick_single_folder() -> Option<String> { None }
    pub fn launch_in_browser(_uri: String) -> bool { false }
}

// 导出非 Windows 平台的空实现
#[cfg(not(windows))]
pub use smtc_flutter::*;
#[cfg(not(windows))]
pub use utils::*;

// 导出 logger
pub use logger::*;

pub use tag_reader::*;
