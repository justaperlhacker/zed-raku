use zed_extension_api::{self as zed, settings::LspSettings, LanguageServerId, Result};

const SERVER_ID: &str = "raku-navigator";
const SERVER_BINARY: &str = "raku-navigator";
const SERVER_SCRIPT: &str = "server/out/server.js";

struct RakuExtension;

impl RakuExtension {
    fn resolve_server_command(
        &mut self,
        _language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        // RakuNavigator is not published to npm, so we can't manage the install
        // for the user. Instead we look for an explicitly configured `path` to
        // `server.js`, then a `raku-navigator` executable on the PATH.
        let configured_path = LspSettings::for_worktree(SERVER_ID, worktree)
            .ok()
            .and_then(|settings| settings.settings)
            .and_then(|settings| {
                settings
                    .get("path")
                    .and_then(|path| path.as_str())
                    .map(str::to_string)
            });

        if let Some(path) = configured_path {
            return Ok(zed::Command {
                command: zed::node_binary_path()?,
                args: vec![path, "--stdio".to_string()],
                env: Default::default(),
            });
        }

        if let Some(path) = worktree.which(SERVER_BINARY) {
            return Ok(zed::Command {
                command: path,
                args: vec!["--stdio".to_string()],
                env: Default::default(),
            });
        }

        Err(format!(
            "Raku Navigator was not found. Install it with:\n\
             \n\
             git clone https://github.com/bscan/RakuNavigator\n\
             cd RakuNavigator && npm install && npm run compile\n\
             \n\
             then point this extension at `{SERVER_SCRIPT}`:\n\
             \n\
             \"lsp\": {{ \"{SERVER_ID}\": {{ \"settings\": {{ \"path\": \"/path/to/RakuNavigator/{SERVER_SCRIPT}\" }} }} }}\n\
             \n\
             Alternatively, put a `{SERVER_BINARY}` executable on your PATH."
        ))
    }
}

impl zed::Extension for RakuExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        self.resolve_server_command(language_server_id, worktree)
    }

    fn language_server_workspace_configuration(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<Option<zed::serde_json::Value>> {
        let settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree)
            .ok()
            .and_then(|settings| settings.settings.clone())
            .unwrap_or_default();
        Ok(Some(settings))
    }
}

zed::register_extension!(RakuExtension);
