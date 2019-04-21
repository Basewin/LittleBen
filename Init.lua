-- Import libraries
local AddOnName, JAN = ...--插件名称，里是  和一个空的表JAN

local pairs = pairs--把pairs变成局部变量

LibStub("AceAddon-3.0"):NewAddon(JAN, AddOnName, "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnName, true)--翻译加载库
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(L["Little Ben write it down"], {
	type = "data source",
	text = "JAN",
	icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp",
	OnClick = function() JAN:OpenOptionFrame() end,
})

JAN.L, JAN.LDB = L, LDB
JAN.Base = {}
JAN.Config = {}
JAN.DataBase = {}
local B, C, DB = JAN.Base, JAN.Config, JAN.DataBase

-- Base
B.AddonName = L["Little Ben write it down"]
B.Version = GetAddOnMetadata(AddOnName, "Version")
B.AddonMsgPrefix = "JAN"

-- 配置
JAN.Config.ModulesOrder = {}
JAN.Config.ModulesOption = {}
function JAN.Config.CreateOptionTable()--创建选项表
	local tempOptionsTable = {
		type = "group",
		name = B.ColorString(B.AddonName).." - "..B.Version,
		args = {
			author = {
				order = 1,
				name = L["Author"]..": "..B.ColorString("盧卡斯-安苏(CN)", 0, 1, 0.59),
				type = "description",--描述
			},

			enable = {
				order = 2,
				name = L["Minimap icon"],
				desc = L["Enables / disables minimap icon"],
				type = "toggle",--这是一个切换按钮
				set = function(info,val)
					DB.profile.minimapicon.hide = not val
					if val then --val每运行一轮，值就变了，不知道在哪变的
						LibStub("LibDBIcon-1.0"):Show(L["Little Ben write it down"])
					else
						LibStub("LibDBIcon-1.0"):Hide(L["Little Ben write it down"]) 
					end
				end,

				get = function(info) --get请求，当小图标val是真时，info是假，但返回真
					return not DB.profile.minimapicon.hide 
				end
			},
			addondesctitle = {
				order = 3,
				type = "header",--页眉
				name = L["Description"],--简介
			},
			addondesctext = {
				order = 4,
				type = "description",--简介
				name =L["Little Ben is a World of Warcraft notebook. Write down what you want to write down at any time."],

			},
			github = {
				order = 5,
				type  = "input",--输入框
				width = "full",--宽度 满
				name  = L["Little Ben on Github"],
				get   = function(info) return "https://github.com/" end,
				set   = function(info) return "https://github.com/" end,
			},
			moduleconfigtitle = {
				order = 6,
				type = "header",--页眉
				name = L["Modules"],--模块   模块内容应该在Modules文件中继承
			},
		}
	}

	for k, v in pairs(JAN.Config.ModulesOption) do--创建选项表完成
		tempOptionsTable.args[k] = v
		tempOptionsTable.args[k].order = JAN.Config.ModulesOrder[k]
	end

	return tempOptionsTable
end

-- DataBase
DB.defaults = {
	profile = {
		enable = true,
		minimapicon = {
			hide = false,
		},
		modules = {},
	}
}

-- Functions
local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return format("%02x%02x%02x", r*255, g*255, b*255)
end

function B.ColorString(str, r, g, b)
	local hex
	local coloredString
	
	if r and g and b then
		hex = RGBToHex(r, g, b)
	else
		hex = RGBToHex(52/255, 152/255, 219/255)
	end
	
	coloredString = "|cff"..hex..str.."|r"
	return coloredString
end

function B.Round(number, decimals)
	return (("%%.%df"):format(decimals)):format(number)
end

function table.pack(...)
	return { n = select("#", ...), ... }
end

function JAN:OnInitialize()--关于初始化
    self:SetUpConfig()
	self:RegisterChatCommand("JAN", "OpenOptionFrame")
	C_ChatInfo.RegisterAddonMessagePrefix(B.AddonMsgPrefix)
end

function JAN:SetUpConfig()--配置设置
	DB.db = LibStub("AceDB-3.0"):New(AddOnName.."DB", DB.defaults)
	DB.profile = DB.db.profile
	DB.profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(DB.db)

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName, function() return C.CreateOptionTable() end)--1.1注册Option主页的内容名为AddOnName， 数据为CreateOptionTable
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName.."Profiles", DB.profileOptions)--2.1注册"配置文件"名为 AddOnName.."Profiles"     数据为DB.profileOptions 


    self.optionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, B.AddonName)--添加到Bliz选项  把"配置设置"添加到   1.2配置对话框
	self.optionFrame.profilePanel = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName.."Profiles", L["Profiles"], B.AddonName)--L["Profiles"]="配置设置"   2.2




    local logo = CreateFrame('Frame', nil, self.optionFrame)--在 optionFrame 新建一个 logo 图标
    logo:SetFrameLevel(4)
    logo:SetSize(128, 64)
    logo:SetPoint('TOPRIGHT', -12, -12)
    logo:SetBackdrop({bgFile = ('Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp'):format(AddOnName)})--图转乘
    self.optionFrame.logo = logo

    LibStub("LibDBIcon-1.0"):Register(L["Little Ben write it down"], self.LDB, DB.profile.minimapicon)
end

function JAN:OpenOptionFrame()--开放选项帧 
    InterfaceOptionsFrame_OpenToCategory(self.optionFrame.profilePanel)--1.3开放选项帧 
    InterfaceOptionsFrame_OpenToCategory(self.optionFrame)
end
