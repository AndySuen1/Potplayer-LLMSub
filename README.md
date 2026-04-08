# PotPlayer-LLMSub

支持远程或本地大语言模型的 PotPlayer 实时字幕翻译插件。

## 功能

- 实时翻译 PotPlayer 播放视频的字幕
- 支持任意兼容 Ollama `/api/generate` 接口的本地或远程 LLM
- 支持自定义翻译提示词（Prompt）
- 支持多种源语言与目标语言

## 安装

1. 将 `SubtitleTranslate - LLMSub.as` 和 `SubtitleTranslate - LLMSub.ico` 复制到 PotPlayer 字幕翻译插件目录：

   ```
   C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate\
   ```

2. 重启 PotPlayer。

## 配置

在 PotPlayer 中打开字幕翻译设置，选择 **LLMSub**，填写以下信息：

### Model & API URL 字段

格式：`模型名称&API地址[&额外提示词]`

| 参数 | 说明 | 示例 |
|------|------|------|
| 模型名称 | 使用的 LLM 模型名 | `qwen2.5:7b` |
| API 地址 | Ollama 接口地址 | `http://127.0.0.1:11434/v1/chat/completions` |
| 额外提示词（可选） | 附加到默认 Prompt 的翻译要求 | `请保留专有名词不翻译` |

示例：

```
qwen2.5:7b&http://127.0.0.1:11434/v1/chat/completions
```

带额外提示词：

```
qwen2.5:7b&http://127.0.0.1:11434/v1/chat/completions&请保留人名不翻译
```

### API Key 字段

填写对应服务的 API Key。使用本地 Ollama 时可填写任意非空字符串，如 `ollama`。

## 默认翻译行为

- 目标语言：中文
- 温度：0.3
- 最大输出 token：2048
- 禁用模型思考模式（`think: false`）

## 依赖

- [PotPlayer](https://potplayer.daum.net/)
- 兼容 Ollama `/api/generate` 接口的 LLM 服务（如 [Ollama](https://ollama.com/)）
