// 跨平台模块：正常导入
pub mod logger;
pub mod tag_reader;

// Windows 平台：导入完整的 Windows 特定模块
#[cfg(windows)]
pub mod smtc_flutter;

#[cfg(windows)]
pub mod utils;

// 导出跨平台模块
pub use logger::*;
pub use tag_reader::*;

// 非 Windows 平台：提供简化实现
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

    /// for Flutter
    impl SMTCFlutter {
        #[inline]
        pub fn new() -> Self {
            Self
        }

        pub fn subscribe_to_control_events(&self, _sink: StreamSink<SMTCControlEvent>) {
            // SMTC is only available on Windows
        }

        pub fn update_state(&self, _state: SMTCState) {
            // SMTC is only available on Windows
        }

        pub fn update_time_properties(&self, _progress: u32) {
            // SMTC is only available on Windows
        }

        pub fn update_display(
            &self,
            _title: String,
            _artist: String,
            _album: String,
            _duration: u32,
            _path: String,
        ) {
            // SMTC is only available on Windows
        }

        pub fn close(self) {
            // SMTC is only available on Windows
        }
    }
}

#[cfg(not(windows))]
pub mod utils {
    /// path: 文件或文件夹的绝对路径。
    /// 会打开父级目录并选择路径指向的项。
    pub fn show_in_explorer(_path: String) -> bool {
        // File explorer integration is only available on Windows
        // On Android/Linux, this should be handled by Dart layer
        false
    }

    pub fn pick_single_folder() -> Option<String> {
        // Folder picker is only available on Windows
        // On Android/Linux, this should be handled by Dart layer
        None
    }

    pub fn launch_in_browser(uri: String) -> bool {
        // Cross-platform: use system default browser
        #[cfg(target_os = "android")]
        {
            // On Android, this should be handled by Dart layer
            // using url_launcher package
            false
        }

        #[cfg(target_os = "linux")]
        {
            // On Linux, use xdg-open
            match std::process::Command::new("xdg-open")
                .arg(&uri)
                .spawn()
            {
                Ok(_) => true,
                Err(_) => false,
            }
        }

        #[cfg(target_os = "macos")]
        {
            // On macOS, use open command
            match std::process::Command::new("open")
                .arg(&uri)
                .spawn()
            {
                Ok(_) => true,
                Err(_) => false,
            }
        }

        #[cfg(not(any(target_os = "android", target_os = "linux", target_os = "macos")))]
        {
            // Unknown platform, return false
            false
        }
    }
}

// 导出 Windows 特定模块的公共接口
#[cfg(windows)]
pub use smtc_flutter::*;
#[cfg(windows)]
pub use utils::*;

#[cfg(not(windows))]
pub use smtc_flutter::*;
#[cfg(not(windows))]
pub use utils::*;
