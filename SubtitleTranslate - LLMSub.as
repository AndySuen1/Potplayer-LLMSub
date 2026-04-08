/*
	支持远程或本地大语言模型的PotPlayer实时翻译插件
	GitHub: https://github.com/AndySuen1/Potplayer-LLMSub
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 											-> get title for UI
// string GetVersion()											-> get version for manage
// string GetDesc()												-> get detail information
// string GetLoginTitle()										-> get title for login dialog
// string GetLoginDesc()										-> get desc for login dialog
// string GetUserText()											-> get user text for login dialog
// string GetPasswordText()										-> get password text for login dialog
// string ServerLogin(string User, string Pass)							-> login
// string ServerLogout()										-> logout
//------------------------------------------------------------------------------------------------
// array<string> GetSrcLangs() 										-> get source language
// array<string> GetDstLangs() 										-> get target language
// string Translate(string Text, string &in SrcLang, string &in DstLang) 	-> do translate !!

array<string> LangTable = 
{
	"af",
	"sq",
	"am",
	"ar",
	"hy",
	"az",
	"eu",
	"be",
	"bn",
	"bs",
	"bg",
	"my",
	"ca",
	"ceb",
	"ny",
	"zh",
	"zh-CN",
	"zh-TW",
	"co",
	"hr",
	"cs",
	"da",
	"nl",
	"en",
	"eo",
	"et",
	"tl",
	"fi",
	"fr",
	"fy",
	"gl",
	"ka",
	"de",
	"el",
	"gu",
	"ht",
	"ha",
	"haw",
	"iw",
	"hi",
	"hmn",
	"hu",
	"is",
	"ig",
	"id",
	"ga",
	"it",
	"ja",
	"jw",
	"kn",
	"kk",
	"km",
	"ko",
	"ku",
	"ky",
	"lo",
	"la",
	"lv",
	"lt",
	"lb",
	"mk",
	"ms",
	"mg",
	"ml",
	"mt",
	"mi",
	"mr",
	"mn",
	"my",
	"ne",
	"no",
	"ps",
	"fa",
	"pl",
	"pt",
	"pa",
	"ro",
	"romanji",
	"ru",
	"sm",
	"gd",
	"sr",
	"st",
	"sn",
	"sd",
	"si",
	"sk",
	"sl",
	"so",
	"es",
	"su",
	"sw",
	"sv",
	"tg",
	"ta",
	"te",
	"th",
	"tr",
	"uk",
	"ur",
	"uz",
	"vi",
	"cy",
	"xh",
	"yi",
	"yo",
	"zu"
};

string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";

string GetTitle()
{
	return "{$CP949=LLMSub$}{$CP950=LLMSub$}{$CP0=LLMSub$}";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return "<a href=\"https://github.com/AndySuen1/Potplayer-LLMSub\">https://github.com/AndySuen1/Potplayer-LLMSub</a>";
}

string GetLoginTitle()
{
	return "Model&API_Key&Prompt";
}

string GetLoginDesc()
{
	return "Input model & api_url & prompt and API key";
}

string GetUserText()
{
	return "Model&API URL:";
}

string GetPasswordText()
{
	return "API Key:";
}

string model;
string api_url;
string api_key;
string extra_prompt;

array<string> split(string str, string delimiter) 
{
	array<string> parts;
	int startPos = 0;
	while (true) {
		int index = str.findFirst(delimiter, startPos);
		if (index == -1) {
			parts.insertLast(str.substr(startPos));
			break;
		}
		else {
			parts.insertLast(str.substr(startPos, index - startPos));
			startPos = index + delimiter.length();
		}
	}
	return parts;
}

string ServerLogin(string User, string Pass)
{
	array<string> settings = split(User, "&");
	if (settings.length() < 2) return "fail: invalid model&api_url format";

	model = settings[0];
	api_url = settings[1];
	api_key = Pass;

	// 如果有第三个字段，作为额外的翻译要求
	if (settings.length() >= 3)
	{
		extra_prompt = settings[2];
	}
	else
	{
		extra_prompt = "";
	}

	if (model.empty() || api_url.empty() || api_key.empty()) return "fail";
	return "200 ok";
}

void ServerLogout()
{
	api_key = "";
}

array<string> GetSrcLangs()
{
	array<string> ret = LangTable;
	
	ret.insertAt(0, ""); // empty is auto
	return ret;
}

array<string> GetDstLangs()
{
	array<string> ret = LangTable;
	return ret;
}

string Translate(string Text, string &in SrcLang, string &in DstLang)
{
	if (api_key.empty()) return "Error: API key not set";
	if (Text.empty()) return "";

	// 构建请求URL - 改用 /api/generate 接口以支持禁用 thinking
	string url = api_url;
	url.replace("localhost", "127.0.0.1");
	url.replace("/v1/chat/completions", "/api/generate");

	// 构建提示词
	string promptText = Text;
	// 处理基本转义字符
	promptText.replace("\\", "\\\\");
	promptText.replace("\"", "\\\"");
	promptText.replace("\n", "\\n");
	promptText.replace("\r", "\\r");
	promptText.replace("\t", "\\t");

	// 构建请求体 - 使用 /api/generate 格式
	string promptBase = "You are a professional translator. Translate the following text to Chinese that is accurate, natural, fluent, avoids translationese, fits Chinese context, and flows smoothly between sentences. Only output the translated text, no explanations, notes, or quotes.";
	if (!extra_prompt.empty())
	{
		// 转义 extra_prompt 中的特殊字符
		string ep = extra_prompt;
		ep.replace("\\", "\\\\");
		ep.replace("\"", "\\\"");
		promptBase = promptBase + " " + ep;
	}

	string Post = "{\"model\":\"" + model + "\",";
	Post += "\"prompt\":\"" + promptBase + ":\\n\\n" + promptText + "\",";
	Post += "\"think\":false,";
	Post += "\"options\":{\"temperature\":0.3,\"num_predict\":2048}}";

	// 发送请求
	string ret = "";
	uintptr http = HostOpenHTTP(url, UserAgent, "Content-Type: application/json", Post);
	if (http != 0)
	{
		string json = HostGetContentHTTP(http);
		HostCloseHTTP(http);

		if (json.empty())
		{
			return "Error: Empty response";
		}

		// 处理流式输出：解析每一行 JSON，拼接所有 response
		string fullResponse = "";
		int pos = 0;
		while (pos >= 0 && pos < int(json.length()))
		{
			int lineEnd = json.findFirst("\n", pos);
			if (lineEnd < 0) lineEnd = int(json.length());

			int lineLen = lineEnd - pos;
			if (lineLen > 0)
			{
				string line = json.substr(pos, lineLen);

				// 解析这一行 JSON
				JsonReader Reader;
				JsonValue Root;
				if (Reader.parse(line, Root) && Root.isObject())
				{
					JsonValue response = Root["response"];
					if (response.isString())
					{
						fullResponse = fullResponse + response.asString();
					}
				}
			}

			pos = lineEnd + 1;
		}

		if (fullResponse.length() > 0)
		{
			ret = fullResponse;
		}
	}
	else
	{
		return "Error: HTTP failed";
	}

	SrcLang = "UTF8";
	DstLang = "UTF8";
	return ret;
}
