
-- #############################################################################
-- #  SECTION INDEX  (grep a tag like [SEC-09] to jump straight to it)
-- #############################################################################
--   [SEC-01] HEADER / REQUIRES & GLOBALS.............................. L28
--   [SEC-02] UI / DRAWING & NOTIFICATION HELPERS...................... L200
--   [SEC-03] UI WIDGET HELPERS / MENU CONSTRUCTION.................... L540
--   [SEC-04] MENU TABS (MISC / EXPLOITS / AIMBOT / MOVEMENT / EXTRAS). L3615
--   [SEC-05] CONFIG SAVE / LOAD (serialize / deserialize)............. L5197
--   [SEC-06] ANTI-AIM BUILDER - STATE ACCESSORS....................... L6572
--   [SEC-07] MANUAL YAW............................................... L6728
--   [SEC-08] MOVEMENT STATE DETECTION................................. L6917
--   [SEC-09] SAFE HEAD................................................ L6954
--   [SEC-10] AIMBOT / PEEK ASSIST..................................... L7897
--   [SEC-11] BREAK LAG COMPENSATION / LEGIT AA........................ L8264
--   [SEC-12] FREESTANDING............................................. L8583
--   [SEC-13] DEFENSIVE MANAGER........................................ L8773
--   [SEC-14] ANTI-BRUTE............................................... L9971
--   [SEC-15] DEFENSIVE SNAPSHOT....................................... L10267
--   [SEC-16] ANTI-AIM UPDATER (YAW / BODY YAW / MODIFIER MATH)........ L10400
--   [SEC-17] FAKELAG MANAGER.......................................... L11627
--   [SEC-18] ANTI-AIM MAIN UPDATE (ORCHESTRATOR)...................... L11666
--   [SEC-19] RUNTIME / VISUALS / EVENT HANDLERS....................... L11967
--   [SEC-22] HC CONDITIONS (AIMBOT-LEVEL CONDITIONAL HITCHANCE)......... L3995
-- #############################################################################

-- #############################################################################
-- #  [SEC-01] HEADER / REQUIRES & GLOBALS
-- #############################################################################
bs_v1 = "bluesense"

pcall(files.create_folder, "nl\\bluesense")

bs_pui = require("neverlose/pui")
bs_base64 = require("neverlose/base64")
bs_clipboard = require("neverlose/clipboard")
bs_inspect = require("neverlose/inspect")
bs_smoothy = require("neverlose/smoothy")
bs_easing = require("neverlose/easing")
bs_defensive_ok, bs_defensive_lib = pcall(require, "neverlose/get_defensive")

function bs_is_defensive()
	if bs_defensive_ok and type(bs_defensive_lib) == "function" then
		local var_1_0, var_1_1 = pcall(bs_defensive_lib)

		if var_1_0 then
			return var_1_1 == true
		end
	end

	local var_1_2, var_1_3 = pcall(function()
		return rage.exploit:get_defensive()
	end)

	return var_1_2 and var_1_3 == true
end

function bs_iter_players(arg_3_0, arg_3_1, arg_3_2)
	local var_3_0 = entity.get_players(arg_3_0, arg_3_1)

	if type(arg_3_2) == "function" then
		for iter_3_0 = 1, #var_3_0 do
			arg_3_2(var_3_0[iter_3_0])
		end
	end

	return var_3_0
end

ffi.cdef("    int    VirtualFree   (void* lpAddress, unsigned long dwSize, unsigned long dwFreeType);\n    void*  VirtualAlloc  (void* lpAddress, unsigned long dwSize, unsigned long flAllocationType, unsigned long flProtect);\n    int    VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);\n    typedef struct {\n        char  pad0[0x60];\n        void* pEntity;\n        void* pActiveWeapon;\n        void* pLastActiveWeapon;\n        float flLastUpdateTime;\n        int   iLastUpdateFrame;\n        float flLastUpdateIncrement;\n        float flEyeYaw;\n        float flEyePitch;\n        float flGoalFeetYaw;\n        float flLastFeetYaw;\n        float flMoveYaw;\n        float flLastMoveYaw;\n        float flLeanAmount;\n        char  pad1[0x4];\n        float flFeetCycle;\n        float flMoveWeight;\n        float flMoveWeightSmoothed;\n        float flDuckAmount;\n        float flHitGroundCycle;\n        float flRecrouchWeight;\n        float vecOriginX; float vecOriginY; float vecOriginZ;\n        float vecLastOriginX; float vecLastOriginY; float vecLastOriginZ;\n        float vecVX; float vecVY; float vecVZ;\n        float vecVNX; float vecVNY; float vecVNZ;\n        float vecVNNZX; float vecVNNZY; float vecVNNZZ;\n        float flVelocityLenght2D;\n        float flJumpFallVelocity;\n        float flSpeedNormalized;\n        float flRunningSpeed;\n        float flDuckingSpeed;\n        float flDurationMoving;\n        float flDurationStill;\n        bool  bOnGround;\n        bool  bHitGroundAnimation;\n        char  pad2[0x2];\n        float flNextLowerBodyYawUpdateTime;\n        float flDurationInAir;\n        float flLeftGroundHeight;\n        float flHitGroundWeight;\n        float flWalkToRunTransition;\n        char  pad3[0x4];\n        float flAffectedFraction;\n        char  pad4[0x208];\n        float flMinBodyYaw;\n        float flMaxBodyYaw;\n        float flMinPitch;\n        float flMaxPitch;\n        int   iAnimsetVersion;\n    } CSGOAnimState_AB_t;\n")

bs_v147 = nil
bs_config = {
	rage = {
		main = {
			dormant_aimbot = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"),
			hide_shots = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
			hide_shots_options = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"),
			double_tap = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
			double_tap_lag_options = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
			double_tap_lag_options_pui = bs_pui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
			peek_assist = {
				switch = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"),
				style = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Style"),
				auto_stop = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Auto Stop"),
				retreat_mode = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Retreat Mode")
			}
		},
		selection = {
			hit_chance = ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"),
			minimum_damage = ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"),
			minimum_damage_global = ui.find("Aimbot", "Ragebot", "Selection", "Global", "Min. Damage"),
			safe_points = ui.find("Aimbot", "Ragebot", "Safety", "Safe Points"),
			body_aim = ui.find("Aimbot", "Ragebot", "Safety", "Body Aim"),
			hitboxes = ui.find("Aimbot", "Ragebot", "Selection", "Hitboxes"),
			autoscope = ui.find("Aimbot", "Ragebot", "Accuracy", "Auto Scope")
		}
	},
	antiaim = {
		angles = {
			enabled = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"),
			pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
			yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
			yaw_base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
			yaw_add = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
			avoid_backstab = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"),
			hidden = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"),
			yaw_modifier = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
			modifier_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
			body_yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
			inverter = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
			left_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
			right_limit = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
			options = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
			freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
			freestand_peek = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
			disable_yaw_modifiers = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"),
			body_freestanding = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding")
		},
		fake_lag = {
			enabled = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
			limit = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
			variability = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Variability"),
			enabled_pui = bs_pui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
			limit_pui = bs_pui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit")
		},
		misc = {
			fake_duck = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
			slow_walk = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
			leg_movement = ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement")
		}
	},
	ping_spike = ui.find("Miscellaneous", "Main", "Other", "Fake Latency"),
	visuals = {
		weapon_chams = ui.find("Visuals", "Players", "Self", "Chams", "Weapon"),
		thirdperson = ui.find("Visuals", "World", "Main", "Force Thirdperson")
	}
}
bs_states = {
	states = {
		"standing",
		"running",
		"crouching",
		"sneaking",
		"slowing",
		"air crouching",
		"air",
		"fakelag",
		"legit aa"
	}
}
bs_logger = {
	message = function(arg_4_0, arg_4_1)
		print_raw(string.format("\a%sbluesense\aDEFAULT  %s", ui.get_style()["Link Active"]:to_hex(), arg_4_1))
	end,
	error = function(arg_5_0, arg_5_1)
		print_raw(string.format("\a%sbluesense\aDEFAULT  \aFF3E3EFF%s", ui.get_style()["Link Active"]:to_hex(), arg_5_1))
	end
}
bs_screen_size = render.screen_size()
bs_drag_state = nil
bs_net_channel = nil
bs_ui_cache = {}
bs_watermark_data = nil
bs_tab_dummy = nil
bs_font_12 = render.load_font("Verdana", 12, "ab")
bs_font_10 = render.load_font("Verdana", 10, "ab")
bs_font_14 = render.load_font("Verdana", 14, "ab")
bs_font_13 = render.load_font("Verdana", 13, "ab")
bs_font_12b = render.load_font("Verdana", 12, "ab")
bs_font_11 = render.load_font("Verdana", 11, "ab")
bs_scope_data = nil
bs_ui_elements = {}
bs_ui_elements2 = render.load_font("Verdana", 24, "ab")
bs_font_10b = render.load_font("Verdana", 10, "ab")
bs_font_14b = render.load_font("Verdana", 14, "ab")
bs_font_13b = render.load_font("Verdana", 13, "ab")
bs_font_12c = render.load_font("Verdana", 12, "ab")
bs_font_24b = render.load_font("Verdana", 24, "ab")
bs_scope_zoom = nil
bs_round_cbs = {}
bs_active_hc_state = nil

function bs_add_round_cb(arg_6_0)
	table.insert(bs_round_cbs, arg_6_0)
end

bs_confirm_anim = {
	rmb_was_down = false,
	anim = 0,
	visible = false,
	hover_no = false,
	hover_yes = false
}
bs_drag_anim = {
	any_dragging = false,
	anim = 0
}

-- #############################################################################
-- #  [SEC-02] UI / DRAWING & NOTIFICATION HELPERS
-- #############################################################################
function bs_draw_crosshair(arg_7_0, arg_7_1)
	if arg_7_1 < 0.01 then
		return
	end

	local var_7_0 = math.floor(arg_7_0.x * 0.5)
	local var_7_1 = math.floor(arg_7_0.y * 0.5)
	local var_7_2 = math.floor(arg_7_1 * 80)
	local var_7_3 = math.floor(arg_7_1 * 30)
	local var_7_4 = 8
	local var_7_5 = 5
	local var_7_6 = 0

	while var_7_6 < arg_7_0.y do
		render.rect(vector(var_7_0, var_7_6), vector(var_7_0 + 1, math.min(var_7_6 + var_7_4, arg_7_0.y)), color(150, 195, 255, var_7_3))

		var_7_6 = var_7_6 + var_7_4 + var_7_5
	end

	local var_7_7 = 7

	render.line(vector(var_7_0 - var_7_7, var_7_1), vector(var_7_0 + var_7_7, var_7_1), color(150, 195, 255, var_7_2))
	render.line(vector(var_7_0, var_7_1 - var_7_7), vector(var_7_0, var_7_1 + var_7_7), color(150, 195, 255, var_7_2))
	render.rect(vector(var_7_0 - 1, var_7_1 - 1), vector(var_7_0 + 2, var_7_1 + 2), color(150, 195, 255, math.floor(arg_7_1 * 160)))
end

bs_notif_cache = nil
bs_hud_theme = nil

function bs_get_notif_ui()
	if bs_hud_theme then
		return bs_hud_theme
	end

	if bs_notif_cache then
		return bs_notif_cache
	end

	local var_8_0, var_8_1 = pcall(function()
		return {
			accent = ui.find("Scripts", "bluesense", "bluesense", "         ", "notifications", "\a666666FFaccent"),
			glass = ui.find("Scripts", "bluesense", "bluesense", "         ", "notifications", "\a666666FFglass tint"),
			border = ui.find("Scripts", "bluesense", "bluesense", "         ", "notifications", "\a666666FFborder"),
			text = ui.find("Scripts", "bluesense", "bluesense", "         ", "notifications", "text"),
			blur = ui.find("Scripts", "bluesense", "bluesense", "         ", "notifications", "\a666666FFbackground blur")
		}
	end)

	if var_8_0 and var_8_1 and var_8_1.accent then
		bs_notif_cache = var_8_1

		return bs_notif_cache
	end

	return nil
end

function bs_get_accent()
	if menu and menu.info and menu.info.hud and menu.info.hud.master_en then
		local var_10_0, var_10_1 = pcall(function()
			return menu.info.hud.master_en:get()
		end)

		if var_10_0 and var_10_1 and menu.info.hud.theme_col then
			local var_10_2, var_10_3 = pcall(function()
				return menu.info.hud.theme_col:get()
			end)

			if var_10_2 and var_10_3 then
				return var_10_3
			end
		end
	end

	if bs_hud_theme and bs_hud_theme.col_accent then
		local var_10_4, var_10_5 = pcall(function()
			return bs_hud_theme.col_accent:get()
		end)

		if var_10_4 and var_10_5 then
			return var_10_5
		end
	end

	local var_10_6 = bs_get_notif_ui()
	local var_10_7 = var_10_6 and var_10_6.accent and pcall(function()
		return var_10_6.accent:get()
	end)
	local var_10_8

	return var_10_7 and var_10_8 or color(150, 195, 255, 255)
end

function bs_get_glass()
	if bs_hud_theme and bs_hud_theme.col_glass then
		local var_15_0, var_15_1 = pcall(function()
			return bs_hud_theme.col_glass:get()
		end)

		if var_15_0 and var_15_1 then
			return var_15_1
		end
	end

	local var_15_2 = bs_get_notif_ui()
	local var_15_3 = var_15_2 and var_15_2.glass and pcall(function()
		return var_15_2.glass:get()
	end)
	local var_15_4

	return var_15_3 and var_15_4 or color(255, 255, 255, 18)
end

function bs_get_border()
	if bs_hud_theme and bs_hud_theme.col_border then
		local var_18_0, var_18_1 = pcall(function()
			return bs_hud_theme.col_border:get()
		end)

		if var_18_0 and var_18_1 then
			return var_18_1
		end
	end

	local var_18_2 = bs_get_notif_ui()
	local var_18_3 = var_18_2 and var_18_2.border and pcall(function()
		return var_18_2.border:get()
	end)
	local var_18_4

	return var_18_3 and var_18_4 or color(255, 255, 255, 45)
end

function bs_get_text()
	if bs_hud_theme and bs_hud_theme.col_text then
		local var_21_0, var_21_1 = pcall(function()
			return bs_hud_theme.col_text:get()
		end)

		if var_21_0 and var_21_1 then
			return var_21_1
		end
	end

	local var_21_2 = bs_get_notif_ui()
	local var_21_3 = var_21_2 and var_21_2.text and pcall(function()
		return var_21_2.text:get()
	end)
	local var_21_4

	return var_21_3 and var_21_4 or color(220, 220, 225, 255)
end

function bs_blur_func()
	if bs_hud_theme and bs_hud_theme.blur then
		local var_24_0, var_24_1 = pcall(function()
			return bs_hud_theme.blur:get()
		end)

		if var_24_0 then
			return var_24_1
		end
	end

	local var_24_2 = bs_get_notif_ui()
	local var_24_3 = var_24_2 and var_24_2.blur and pcall(function()
		return var_24_2.blur:get()
	end)
	local var_24_4

	return var_24_3 == nil or var_24_3 and var_24_4 or true
end

function bs_draw_panel_bg(arg_27_0, arg_27_1, arg_27_2)
	if not (ui.get_alpha() > 0) then
		return
	end

	if arg_27_2 < 0.005 then
		return
	end

	local var_27_0 = bs_get_glass()
	local var_27_1 = bs_get_border()
	local var_27_2 = bs_blur_func()
	local var_27_3 = 6
	local var_27_4 = math.floor(arg_27_1.x * 0.5)
	local var_27_5 = math.floor(arg_27_1.y * 0.5)
	local var_27_6 = math.floor(arg_27_0.x) - var_27_4
	local var_27_7 = math.floor(arg_27_0.y) - var_27_5
	local var_27_8 = math.floor(arg_27_0.x) + var_27_4
	local var_27_9 = math.floor(arg_27_0.y) + var_27_5
	local var_27_10 = math.floor(arg_27_2 * 255)
	local var_27_11 = math.floor(var_27_10 * 0.08)

	if var_27_11 > 1 then
		render.rect(vector(var_27_6 - 2, var_27_7 - 1), vector(var_27_8 + 2, var_27_9 + 3), color(0, 0, 0, var_27_11), var_27_3 + 2)
	end

	if var_27_2 and var_27_10 > 10 then
		render.blur(vector(var_27_6, var_27_7), vector(var_27_8, var_27_9), 4, arg_27_2 * 0.5, var_27_3)
		render.blur(vector(var_27_6, var_27_7), vector(var_27_8, var_27_9), 2, arg_27_2 * 0.3, var_27_3)
	end

	local var_27_12 = math.floor(var_27_0.a * arg_27_2 * 0.55)

	render.rect(vector(var_27_6, var_27_7), vector(var_27_8, var_27_9), color(var_27_0.r, var_27_0.g, var_27_0.b, var_27_12), var_27_3)
	render.rect(vector(var_27_6 + 1, var_27_7 + 1), vector(var_27_8 - 1, var_27_7 + 1 + math.floor((var_27_9 - var_27_7) * 0.35)), color(255, 255, 255, math.floor(var_27_10 * 0.04)), var_27_3)
	render.rect_outline(vector(var_27_6, var_27_7), vector(var_27_8, var_27_9), color(var_27_1.r, var_27_1.g, var_27_1.b, math.floor(var_27_1.a * arg_27_2 * 0.6)), 1, var_27_3)
end

bs_confirm_yes_a = 0
bs_confirm_no_a = 0

function bs_draw_confirm(arg_28_0)
	bs_v973 = bs_confirm_anim.anim

	if bs_v973 < 0.005 then
		return
	end

	bs_v985 = bs_get_glass()
	bs_v998 = bs_get_border()
	bs_v1007 = bs_get_accent()
	bs_v1008 = bs_get_text()
	bs_v1009 = bs_blur_func()
	bs_v1010 = 210
	bs_v1011 = 82
	bs_v1012 = math.floor(arg_28_0.x * 0.5 - bs_v1010 * 0.5)
	bs_v975 = math.floor(arg_28_0.y * 0.5 - bs_v1011 * 0.5 - 20)
	bs_v976 = (1 - bs_v973) * (bs_v1011 + 14)
	bs_v974 = bs_v975 + math.floor(bs_v976 * (1 - bs_v973))
	bs_v977 = bs_v973
	bs_v978 = math.floor(bs_v977 * 255)
	bs_v979 = 6
	bs_v980 = math.floor(bs_v978 * 0.18)

	if bs_v980 > 1 then
		render.rect(vector(bs_v1012 - 3, bs_v974 - 2), vector(bs_v1012 + bs_v1010 + 3, bs_v974 + bs_v1011 + 4), color(0, 0, 0, bs_v980), bs_v979 + 3)
	end

	if bs_v1009 and bs_v978 > 10 then
		render.blur(vector(bs_v1012, bs_v974), vector(bs_v1012 + bs_v1010, bs_v974 + bs_v1011), 6, bs_v977 * 0.85, bs_v979)
		render.blur(vector(bs_v1012, bs_v974), vector(bs_v1012 + bs_v1010, bs_v974 + bs_v1011), 3, bs_v977 * 0.55, bs_v979)
		render.blur(vector(bs_v1012, bs_v974), vector(bs_v1012 + bs_v1010, bs_v974 + bs_v1011), 1, bs_v977 * 0.3, bs_v979)
	end

	render.rect(vector(bs_v1012, bs_v974), vector(bs_v1012 + bs_v1010, bs_v974 + bs_v1011), color(bs_v985.r, bs_v985.g, bs_v985.b, math.floor(bs_v985.a * bs_v977)), bs_v979)
	render.rect(vector(bs_v1012 + 1, bs_v974 + 1), vector(bs_v1012 + bs_v1010 - 1, bs_v974 + 1 + math.floor(bs_v1011 * 0.4)), color(255, 255, 255, math.floor(bs_v978 * 0.07)), bs_v979)
	render.rect_outline(vector(bs_v1012, bs_v974), vector(bs_v1012 + bs_v1010, bs_v974 + bs_v1011), color(bs_v998.r, bs_v998.g, bs_v998.b, math.floor(bs_v998.a * bs_v977)), 1, bs_v979)

	bs_v981 = bs_font_12
	bs_v982 = "bluesense"
	bs_v983 = "  ·  "
	bs_v984 = "reset positions?"
	bs_v986 = render.measure_text(bs_v981, nil, bs_v982)
	bs_v987 = render.measure_text(bs_v981, nil, bs_v983)
	bs_v988 = render.measure_text(bs_v981, nil, bs_v984)
	bs_v989 = bs_v986.x + bs_v987.x + bs_v988.x
	bs_v992 = bs_v1012 + math.floor((bs_v1010 - bs_v989) * 0.5)
	bs_v993 = bs_v974 + 13

	render.text(bs_v981, vector(bs_v992, bs_v993), color(bs_v1007.r, bs_v1007.g, bs_v1007.b, math.floor(bs_v1007.a * bs_v977)), nil, bs_v982)

	bs_v991 = bs_v992 + bs_v986.x

	render.text(bs_v981, vector(bs_v991, bs_v993), color(bs_v1008.r, bs_v1008.g, bs_v1008.b, math.floor(bs_v1008.a * 0.38 * bs_v977)), nil, bs_v983)

	bs_v990 = bs_v991 + bs_v987.x

	render.text(bs_v981, vector(bs_v990, bs_v993), color(bs_v1008.r, bs_v1008.g, bs_v1008.b, math.floor(bs_v1008.a * bs_v977)), nil, bs_v984)

	bs_v994 = 82
	bs_v995 = 24
	bs_v996 = bs_v974 + bs_v1011 - bs_v995 - 10
	bs_v997 = bs_v1012 + math.floor(bs_v1010 * 0.5) - bs_v994 - 5
	bs_v999 = bs_v1012 + math.floor(bs_v1010 * 0.5) + 5
	bs_v1000 = 5
	bs_v1001 = ui.get_mouse_position()
	bs_confirm_anim.hover_yes = bs_v997 <= bs_v1001.x and bs_v1001.x <= bs_v997 + bs_v994 and bs_v996 <= bs_v1001.y and bs_v1001.y <= bs_v996 + bs_v995
	bs_confirm_anim.hover_no = bs_v999 <= bs_v1001.x and bs_v1001.x <= bs_v999 + bs_v994 and bs_v996 <= bs_v1001.y and bs_v1001.y <= bs_v996 + bs_v995
	bs_v1002 = 0.18
	bs_confirm_yes_a = bs_confirm_yes_a + ((bs_confirm_anim.hover_yes and 1 or 0) - bs_confirm_yes_a) * bs_v1002
	bs_confirm_no_a = bs_confirm_no_a + ((bs_confirm_anim.hover_no and 1 or 0) - bs_confirm_no_a) * bs_v1002
	bs_v1003 = bs_confirm_yes_a
	bs_v1004 = bs_confirm_no_a

	function bs_v1005(arg_29_0)
		if bs_v1009 and bs_v978 > 10 then
			render.blur(vector(arg_29_0, bs_v996), vector(arg_29_0 + bs_v994, bs_v996 + bs_v995), 4, bs_v977 * 0.55, bs_v1000)
		end

		render.rect(vector(arg_29_0, bs_v996), vector(arg_29_0 + bs_v994, bs_v996 + bs_v995), color(bs_v985.r, bs_v985.g, bs_v985.b, math.floor(bs_v985.a * bs_v977 * 1.3)), bs_v1000)

		if bs_v1003 > 0.005 then
			render.rect(vector(arg_29_0, bs_v996), vector(arg_29_0 + bs_v994, bs_v996 + bs_v995), color(bs_v1007.r, bs_v1007.g, bs_v1007.b, math.floor(bs_v977 * bs_v1003 * 60)), bs_v1000)
		end

		render.rect(vector(arg_29_0 + 1, bs_v996 + 1), vector(arg_29_0 + bs_v994 - 1, bs_v996 + 1 + math.floor(bs_v995 * 0.45)), color(255, 255, 255, math.floor(bs_v978 * 0.08 * (1 + bs_v1003 * 0.5))), bs_v1000)

		bs_v1013 = color(math.floor(bs_v998.r + (bs_v1007.r - bs_v998.r) * bs_v1003), math.floor(bs_v998.g + (bs_v1007.g - bs_v998.g) * bs_v1003), math.floor(bs_v998.b + (bs_v1007.b - bs_v998.b) * bs_v1003), math.floor((bs_v998.a + (bs_v1007.a - bs_v998.a) * bs_v1003) * bs_v977))

		render.rect_outline(vector(arg_29_0, bs_v996), vector(arg_29_0 + bs_v994, bs_v996 + bs_v995), bs_v1013, 1, bs_v1000)

		bs_v1014 = render.measure_text(bs_v981, nil, "yes")
		bs_v1015 = color(math.floor(bs_v1008.r + (bs_v1007.r - bs_v1008.r) * bs_v1003), math.floor(bs_v1008.g + (bs_v1007.g - bs_v1008.g) * bs_v1003), math.floor(bs_v1008.b + (bs_v1007.b - bs_v1008.b) * bs_v1003), math.floor(bs_v977 * (bs_v1008.a * 0.65 + (bs_v1007.a - bs_v1008.a * 0.65) * bs_v1003)))

		render.text(bs_v981, vector(arg_29_0 + math.floor((bs_v994 - bs_v1014.x) * 0.5), bs_v996 + math.floor((bs_v995 - bs_v1014.y) * 0.5)), bs_v1015, nil, "yes")
	end

	function bs_v1006(arg_30_0)
		if bs_v1009 and bs_v978 > 10 then
			render.blur(vector(arg_30_0, bs_v996), vector(arg_30_0 + bs_v994, bs_v996 + bs_v995), 4, bs_v977 * 0.55, bs_v1000)
		end

		render.rect(vector(arg_30_0, bs_v996), vector(arg_30_0 + bs_v994, bs_v996 + bs_v995), color(bs_v985.r, bs_v985.g, bs_v985.b, math.floor(bs_v985.a * bs_v977 * 1.3)), bs_v1000)

		if bs_v1004 > 0.005 then
			render.rect(vector(arg_30_0, bs_v996), vector(arg_30_0 + bs_v994, bs_v996 + bs_v995), color(bs_v1007.r, bs_v1007.g, bs_v1007.b, math.floor(bs_v977 * bs_v1004 * 60)), bs_v1000)
		end

		render.rect(vector(arg_30_0 + 1, bs_v996 + 1), vector(arg_30_0 + bs_v994 - 1, bs_v996 + 1 + math.floor(bs_v995 * 0.45)), color(255, 255, 255, math.floor(bs_v978 * 0.08 * (1 + bs_v1004 * 0.5))), bs_v1000)

		bs_v1016 = color(math.floor(bs_v998.r + (bs_v1007.r - bs_v998.r) * bs_v1004), math.floor(bs_v998.g + (bs_v1007.g - bs_v998.g) * bs_v1004), math.floor(bs_v998.b + (bs_v1007.b - bs_v998.b) * bs_v1004), math.floor((bs_v998.a + (bs_v1007.a - bs_v998.a) * bs_v1004) * bs_v977))

		render.rect_outline(vector(arg_30_0, bs_v996), vector(arg_30_0 + bs_v994, bs_v996 + bs_v995), bs_v1016, 1, bs_v1000)

		bs_v1017 = render.measure_text(bs_v981, nil, "no")
		bs_v1018 = color(math.floor(bs_v1008.r + (bs_v1007.r - bs_v1008.r) * bs_v1004), math.floor(bs_v1008.g + (bs_v1007.g - bs_v1008.g) * bs_v1004), math.floor(bs_v1008.b + (bs_v1007.b - bs_v1008.b) * bs_v1004), math.floor(bs_v977 * (bs_v1008.a * 0.65 + (bs_v1007.a - bs_v1008.a * 0.65) * bs_v1004)))

		render.text(bs_v981, vector(arg_30_0 + math.floor((bs_v994 - bs_v1017.x) * 0.5), bs_v996 + math.floor((bs_v995 - bs_v1017.y) * 0.5)), bs_v1018, nil, "no")
	end

	bs_v1005(bs_v997)
	bs_v1006(bs_v999)
end

-- #############################################################################
-- #  [SEC-03] UI WIDGET HELPERS / MENU CONSTRUCTION
-- #############################################################################
bs_position_dragger = {
	new = function(arg_31_0, arg_31_1, arg_31_2, arg_31_3)
		local var_31_0 = arg_31_2 or vector(0, 0)
		local var_31_1 = ui.create("DRAGGING_" .. arg_31_1)
		local var_31_2 = {
			var_31_1:slider(arg_31_1 .. ":x", -16384, 16384, var_31_0.x),
			var_31_1:slider(arg_31_1 .. ":y", -16384, 16384, var_31_0.y)
		}

		var_31_2[1]:visibility(false)
		var_31_2[2]:visibility(false)

		local var_31_3 = {
			hover_anim = 0,
			dragging = false,
			grab_anim = 0,
			was_dragging = false,
			name = arg_31_1,
			axis = arg_31_3 or "xy",
			initial_pos = var_31_0,
			game_refs = var_31_2,
			position = var_31_0,
			size = vector(0, 0),
			drag_offset = vector(0, 0),
			smooth_x = var_31_0.x,
			smooth_y = var_31_0.y,
			reset_pos = function(arg_32_0)
				arg_32_0.game_refs[1]:set(arg_32_0.initial_pos.x)
				arg_32_0.game_refs[2]:set(arg_32_0.initial_pos.y)

				arg_32_0.smooth_x = arg_32_0.initial_pos.x
				arg_32_0.smooth_y = arg_32_0.initial_pos.y
				arg_32_0.position = vector(arg_32_0.initial_pos.x, arg_32_0.initial_pos.y)

				if arg_32_0.reset_callbacks then
					for iter_32_0, iter_32_1 in ipairs(arg_32_0.reset_callbacks) do
						iter_32_1()
					end
				end
			end,
			on_reset_pos = function(arg_33_0, arg_33_1)
				arg_33_0.reset_callbacks = arg_33_0.reset_callbacks or {}

				table.insert(arg_33_0.reset_callbacks, arg_33_1)
			end,
			set_pos = function(arg_34_0, arg_34_1)
				arg_34_0.game_refs[1]:set(arg_34_1.x)
				arg_34_0.game_refs[2]:set(arg_34_1.y)
			end,
			update = function(arg_35_0, arg_35_1)
				arg_35_0.size = arg_35_1
				bs_v1072 = ui.get_mouse_position()
				bs_v1073 = ui.get_alpha() > 0
				bs_v1074 = render.screen_size()
				bs_v1075 = arg_35_1.x * 0.5
				bs_v1076 = arg_35_1.y * 0.5
				bs_v1077 = arg_35_0.game_refs[1]:get()
				bs_v1078 = arg_35_0.game_refs[2]:get()

				if arg_35_0.axis == "y" then
					bs_v1077 = math.floor(bs_v1074.x * 0.5)

					arg_35_0.game_refs[1]:set(bs_v1077)
				else
					bs_v1080 = math.max(bs_v1075, math.min(bs_v1074.x - bs_v1075, bs_v1077))

					if bs_v1080 ~= bs_v1077 then
						arg_35_0.game_refs[1]:set(bs_v1080)

						bs_v1077 = bs_v1080
					end
				end

				bs_v1079 = math.max(bs_v1076, math.min(bs_v1074.y - bs_v1076, bs_v1078))

				if bs_v1079 ~= bs_v1078 then
					arg_35_0.game_refs[2]:set(bs_v1079)

					bs_v1078 = bs_v1079
				end

				bs_v1059 = false

				if bs_v1073 and bs_tab_dummy then
					bs_v1061, bs_v1063 = pcall(function()
						return bs_tab_dummy:get()
					end)
					bs_v1059 = bs_v1061 and bs_v1063 == 2
				end

				if not bs_v1059 then
					if arg_35_0.dragging then
						bs_scope_zoom = nil
					end

					arg_35_0.dragging = false
					arg_35_0.hover_anim = arg_35_0.hover_anim + (0 - arg_35_0.hover_anim) * 0.12
					arg_35_0.grab_anim = arg_35_0.grab_anim + (0 - arg_35_0.grab_anim) * 0.12
					arg_35_0.smooth_x = arg_35_0.smooth_x + (bs_v1077 - arg_35_0.smooth_x) * 0.13
					arg_35_0.smooth_y = arg_35_0.smooth_y + (bs_v1078 - arg_35_0.smooth_y) * 0.13
					arg_35_0.position = vector(arg_35_0.smooth_x, arg_35_0.smooth_y)

					return
				end

				bs_v1060 = bs_v1073 and common.is_button_down(1)
				bs_v1062 = bs_v1072.x >= bs_v1077 - bs_v1075 and bs_v1072.x <= bs_v1077 + bs_v1075 and bs_v1072.y >= bs_v1078 - bs_v1076 and bs_v1072.y <= bs_v1078 + bs_v1076

				if bs_v1060 and not bs_confirm_anim.visible then
					if not arg_35_0.dragging then
						if bs_v1062 and (bs_scope_zoom == nil or bs_scope_zoom == arg_35_0) then
							arg_35_0.dragging = true
							bs_scope_zoom = arg_35_0
							arg_35_0.drag_offset = vector(bs_v1077 - bs_v1072.x, bs_v1078 - bs_v1072.y)
end

	-- Random mode: pick random desync between set limit and 60 each send tick
	elseif var_376_1 == "random" then
		if arg_376_0.choked_commands == 0 then
			local min_limit = arg_376_2.fake_limit and math.abs(arg_376_2.fake_limit:get()) or 60
			local random_limit = math.random(min_limit, 60)
			var_376_3 = random_limit
			bs_v721 = math.random() > 0.5
			var_376_2 = bs_v721
		end
		
		if arg_376_1._async_yaw_active then
			arg_376_1.left_limit = 60
			arg_376_1.right_limit = 60
		else
			arg_376_1.inverter = var_376_2
			arg_376_1._lr_side = var_376_2
			arg_376_1.left_limit = var_376_3
			arg_376_1.right_limit = var_376_3
		end
	else
						bs_v1065 = bs_v1077
						bs_v1068 = bs_v1072.y + arg_35_0.drag_offset.y

						if arg_35_0.axis == "xy" then
							bs_v1065 = bs_v1072.x + arg_35_0.drag_offset.x
							bs_v1065 = math.max(bs_v1075, math.min(bs_v1074.x - bs_v1075, bs_v1065))
						end

						bs_v1067 = math.max(bs_v1076, math.min(bs_v1074.y - bs_v1076, bs_v1068))

						if arg_35_0.axis ~= "y" then
							arg_35_0.game_refs[1]:set(bs_v1065)
						end

						arg_35_0.game_refs[2]:set(bs_v1067)
					end
				else
					if arg_35_0.dragging then
						bs_scope_zoom = nil
					end

					arg_35_0.dragging = false
				end

				bs_v1064 = bs_v1062 and 1 or 0
				arg_35_0.hover_anim = arg_35_0.hover_anim + (bs_v1064 - arg_35_0.hover_anim) * 0.12
				bs_v1066 = arg_35_0.dragging and 1 or 0
				arg_35_0.grab_anim = arg_35_0.grab_anim + (bs_v1066 - arg_35_0.grab_anim) * (arg_35_0.dragging and 0.22 or 0.09)
				bs_v1069 = arg_35_0.game_refs[1]:get()
				bs_v1070 = arg_35_0.game_refs[2]:get()
				bs_v1071 = arg_35_0.dragging and 1 or 0.13
				arg_35_0.smooth_x = arg_35_0.smooth_x + (bs_v1069 - arg_35_0.smooth_x) * bs_v1071
				arg_35_0.smooth_y = arg_35_0.smooth_y + (bs_v1070 - arg_35_0.smooth_y) * bs_v1071
				arg_35_0.position = vector(arg_35_0.smooth_x, arg_35_0.smooth_y)
				arg_35_0.was_dragging = arg_35_0.dragging
			end
		}

		table.insert(bs_ui_cache, var_31_3)

		return var_31_3
	end
}

events.render(function()
	if not (ui.get_alpha() > 0) then
		bs_confirm_anim.visible = false
		bs_confirm_anim.anim = 0
		bs_confirm_anim.rmb_was_down = false

		return
	end

	local var_37_0 = false

	if bs_tab_dummy then
		local var_37_1, var_37_2 = pcall(function()
			return bs_tab_dummy:get()
		end)

		var_37_0 = var_37_1 and var_37_2 == 2
	end

	local var_37_3 = render.screen_size()
	local var_37_4 = common.is_button_down(2)

	if var_37_0 and var_37_4 and not bs_confirm_anim.rmb_was_down and not bs_confirm_anim.visible then
		bs_confirm_anim.visible = true
		bs_confirm_anim.choice = nil
	end

	bs_confirm_anim.rmb_was_down = var_37_4

	local var_37_5 = bs_confirm_anim.visible and 1 or 0

	bs_confirm_anim.anim = bs_confirm_anim.anim + (var_37_5 - bs_confirm_anim.anim) * 0.18

	if var_37_0 then
		local var_37_6 = false

		for iter_37_0, iter_37_1 in ipairs(bs_ui_cache) do
			if iter_37_1.dragging then
				var_37_6 = true

				break
			end
		end

		bs_drag_anim.anim = bs_drag_anim.anim + ((var_37_6 and 1 or 0) - bs_drag_anim.anim) * 0.15

		bs_draw_crosshair(var_37_3, bs_drag_anim.anim)
	else
		bs_drag_anim.anim = bs_drag_anim.anim + (0 - bs_drag_anim.anim) * 0.15
	end

	if bs_confirm_anim.anim > 0.01 and common.is_button_down(1) and bs_confirm_anim.visible then
		if bs_confirm_anim.hover_yes then
			for iter_37_2, iter_37_3 in ipairs(bs_ui_cache) do
				iter_37_3:reset_pos()
			end

			for iter_37_4, iter_37_5 in ipairs(bs_round_cbs) do
				iter_37_5()
			end

			bs_confirm_anim.visible = false
		elseif bs_confirm_anim.hover_no then
			bs_confirm_anim.visible = false
		end
	end
end)

bs_aspect_old = false

function bs_v482()
	if bs_aspect_old then
		return
	end

	bs_aspect_old = true

	events.render(function()
		if bs_confirm_anim.anim <= 0.01 then
			return
		end

		local var_40_0 = render.screen_size()

		bs_draw_confirm(var_40_0)
	end)
end

bs_reset_cbs = {}
bs_cvar_backup = {
	get_original = function(arg_41_0, arg_41_1)
		return tonumber(arg_41_1:string())
	end
}
bs_bind_names = {
	animate = function(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4)
		if not arg_42_4 or arg_42_4:gsub(" ", "") == "" then
			return arg_42_4
		end

		local var_42_0 = ""
		local var_42_1 = globals.realtime * arg_42_1
		local var_42_2 = 1
		local var_42_3 = #arg_42_4

		while var_42_2 <= var_42_3 do
			local var_42_4 = arg_42_4:byte(var_42_2)

			if (var_42_4 == 208 or var_42_4 == 209) and arg_42_4:byte(var_42_2 + 1) then
				local var_42_5 = arg_42_4:sub(var_42_2, var_42_2 + 1)
				local var_42_6 = (math.sin(var_42_1 + var_42_2 / 3) + 1) / 2

				var_42_0 = var_42_0 .. "\a" .. arg_42_2:lerp(arg_42_3, math.clamp(var_42_6, 0, 1)):to_hex() .. var_42_5
				var_42_2 = var_42_2 + 2
			else
				local var_42_7 = (math.sin(var_42_1 + var_42_2 / 3) + 1) / 2

				var_42_0 = var_42_0 .. "\a" .. arg_42_2:lerp(arg_42_3, math.clamp(var_42_7, 0, 1)):to_hex() .. arg_42_4:sub(var_42_2, var_42_2)
				var_42_2 = var_42_2 + 1
			end
		end

		return var_42_0
	end,
	colored = function(arg_43_0, ...)
		local var_43_0 = ""

		for iter_43_0, iter_43_1 in pairs({
			...
		}) do
			var_43_0 = var_43_0 .. "\a" .. iter_43_1[2]:to_hex() .. iter_43_1[1]
		end

		return var_43_0
	end
}
bs_hotkeys = {}
bs_bind_cache = {}
bs_v484 = {
	[0] = "NONE",
	"M1",
	"M2",
	"M3",
	"M4",
	"M5",
	nil,
	nil,
	"BKSP",
	"TAB",
	nil,
	nil,
	nil,
	"ENTER",
	nil,
	nil,
	"SHIFT",
	"CTRL",
	"ALT",
	nil,
	"CAPS",
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"ESC",
	nil,
	nil,
	nil,
	nil,
	"SPACE",
	"PGUP",
	"PGDN",
	"END",
	"HOME",
	"LEFT",
	"UP",
	"RIGHT",
	"DOWN",
	nil,
	nil,
	nil,
	nil,
	"INS",
	"DEL",
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"F1",
	"F2",
	"F3",
	"F4",
	"F5",
	"F6",
	"F7",
	"F8",
	"F9",
	"F10",
	"F11",
	"F12",
	[219] = "[",
	[189] = "-",
	[222] = "'",
	[188] = ",",
	[221] = "]",
	[191] = "/",
	[220] = "\\",
	[190] = ".",
	[144] = "NUMLK",
	[192] = "`",
	[187] = "=",
	[186] = ";"
}

for iter_0_0 = 48, 57 do
	bs_v484[iter_0_0] = string.char(iter_0_0)
end

for iter_0_1 = 65, 90 do
	bs_v484[iter_0_1] = string.char(iter_0_1)
end

for iter_0_2 = 96, 105 do
	bs_v484[iter_0_2] = "NUM" .. iter_0_2 - 96
end

function bs_hotkeys.update(arg_44_0)
	for iter_44_0 in pairs(bs_bind_cache) do
		bs_bind_cache[iter_44_0] = nil
	end

	for iter_44_1, iter_44_2 in ipairs(ui.get_binds()) do
		bs_bind_cache[iter_44_2.name] = {
			value = iter_44_2.value,
			active = iter_44_2.active,
			mode = iter_44_2.mode
		}
	end
end

function bs_hotkeys.is_active(arg_45_0, arg_45_1)
	local var_45_0 = bs_bind_cache[arg_45_1]

	return var_45_0 and var_45_0.active or false
end

function bs_hotkeys.get_label(arg_46_0, arg_46_1)
	local var_46_0 = bs_bind_cache[arg_46_1]

	if not var_46_0 or var_46_0.value == 0 then
		return "[ - ]"
	end

	return "[ " .. (bs_v484[var_46_0.value] or "K" .. var_46_0.value) .. " ]"
end

function bs_hotkeys.get_state(arg_47_0, arg_47_1)
	local var_47_0 = bs_bind_cache[arg_47_1]

	if not var_47_0 then
		return {
			0,
			false
		}
	end

	return {
		var_47_0.value,
		var_47_0.active
	}
end

bs_menu = {
	info = {}
}

function bs_fmt(arg_48_0)
	local text = tostring(arg_48_0):gsub("(%a)([%w']*)", function(first, rest)
		return first:upper() .. rest
	end)

	return "\aA0A0A0FF" .. text
end

bs_menu_icons = {
	antiaim = ui.get_icon("shield-halved"),
	visuals = ui.get_icon("eye"),
	misc = ui.get_icon("gears")
}
bs_tab_dummy = {
	get = function()
		return 2
	end
}
bs_ui_antiaim = bs_pui.create(bs_menu_icons.antiaim, "   ", 1)
bs_antiaim_tabs = {
	"\f<sliders>\r  General",
	"\f<hammer>\r  Builder",
	"\f<shield>\r  Defensive"
}
bs_tab_general = 1
bs_tab_builder = 2
bs_tab_defensive = 3
bs_tab_sel = bs_ui_antiaim:list("", bs_antiaim_tabs)
bs_sel_selector = bs_ui_antiaim:list("\nSelector", {
	"\f<gear>\r  main",
	"\f<floppy-disk>\r  config"
}):depend({
	bs_tab_sel,
	bs_tab_general
})
bs_cfg_sel_main = 1
bs_cfg_sel_config = 2
bs_grp_icon2 = bs_pui.create(bs_menu_icons.antiaim, "         ", 2)
bs_antiaim_menu = {}
bs_aa_general = {}
bs_aa_tabs = {
	 switch = bs_ui_antiaim:switch("\v\f<robot>\r  AI Peek", false):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_v545 = bs_aa_tabs.switch:create()
bs_aa_tabs.color = bs_v545:color_picker(bs_fmt("color"), color(150, 195, 255, 255))
bs_aa_tabs.switch_to_knife = bs_v545:switch(bs_fmt("knife switch"), false)
bs_aa_general.aipeek = bs_aa_tabs
bs_def_switch = {
	 switch = bs_ui_antiaim:switch("\v\f<plane-up>\r  Air Exploit", false):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_v558 = bs_def_switch.switch:create()
bs_def_switch.visualization = bs_v558:switch(bs_fmt("visualization"), true)
bs_def_switch.color = bs_v558:color_picker(bs_fmt("color"), color(150, 195, 255, 255)):depend({
	bs_def_switch.visualization,
	true
})
bs_aa_general.air_exploit = bs_def_switch
bs_def_group = {
	 switch = bs_ui_antiaim:switch("\v\f<eye-slash>\r  Auto Hide Shots", false):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_def_weapon_sel = bs_def_group.switch:create()
bs_weapon_list = {
	"awp",
	"pistol",
	"auto",
	"scout",
	"deagle/rev"
}
bs_v578 = bs_def_weapon_sel:list(bs_fmt("weapon"), bs_weapon_list)
bs_def_group.wpn_sel = bs_v578
bs_v587 = {
	"standing",
	"running",
	"slowing",
	"crouching",
	"sneaking",
	"air",
	"air crouching"
}
bs_def_group.awp = bs_def_weapon_sel:switch(bs_fmt("enabled"), true):depend({
	bs_v578,
	1
})
bs_def_group.awp_states = bs_def_weapon_sel:selectable(bs_fmt("active on states"), bs_v587):depend({
	bs_v578,
	1
})
bs_def_group.pistol = bs_def_weapon_sel:switch(bs_fmt("enabled"), true):depend({
	bs_v578,
	2
})
bs_def_group.pistol_states = bs_def_weapon_sel:selectable(bs_fmt("active on states"), bs_v587):depend({
	bs_v578,
	2
})
bs_def_group.auto = bs_def_weapon_sel:switch(bs_fmt("enabled"), false):depend({
	bs_v578,
	3
})
bs_def_group.auto_states = bs_def_weapon_sel:selectable(bs_fmt("active on states"), bs_v587):depend({
	bs_v578,
	3
})
bs_def_group.scout = bs_def_weapon_sel:switch(bs_fmt("enabled"), false):depend({
	bs_v578,
	4
})
bs_def_group.scout_states = bs_def_weapon_sel:selectable(bs_fmt("active on states"), bs_v587):depend({
	bs_v578,
	4
})
bs_def_group.deagle = bs_def_weapon_sel:switch(bs_fmt("enabled"), false):depend({
	bs_v578,
	5
})
bs_def_group.deagle_states = bs_def_weapon_sel:selectable(bs_fmt("active on states"), bs_v587):depend({
	bs_v578,
	5
})
bs_aa_general.ahs = bs_def_group
bs_v560 = {
	 enabled = bs_ui_antiaim:switch("\v\f<person-chalkboard>\r  Legit AA"):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_v560.mode = bs_v560.enabled:create():combo(bs_fmt("yaw base"), {
	"local view",
	"at target"
}):depend({
	bs_v560.enabled,
	true
})
bs_aa_general.legit_aa = bs_v560
bs_aa_states_combo = {
	 switch = bs_ui_antiaim:switch("\v\f<rotate>\r  Freestanding"):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_aa_states_combo.static = bs_aa_states_combo.switch:create():switch(bs_fmt("static body yaw"))
bs_aa_general.freestanding = bs_aa_states_combo
bs_def_state_combo = {
	 select = bs_ui_antiaim:combo("\v\f<arrow-right-arrow-left>\r  Manual Yaw", {
		"disabled",
		"left",
		"right",
		"forward",
		"back"
	}):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_body_fs_select = bs_def_state_combo.select:create()
bs_def_state_combo.static = bs_body_fs_select:switch(bs_fmt("static"))
bs_def_state_combo.inverter = bs_body_fs_select:switch(bs_fmt("inverter")):depend({
	bs_def_state_combo.static,
	true
})
bs_def_state_combo.force_static = bs_body_fs_select:switch(bs_fmt("force static"))
bs_def_state_combo.base = bs_body_fs_select:combo(bs_fmt("yaw base"), {
	"local view",
	"at target"
})
bs_aa_general.manual_yaw = bs_def_state_combo
bs_aa_general.avoid_backstab = {
	 switch = bs_grp_icon2:switch("\v\f<shield>\r  Avoid Backstab"):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_v595 = {
	 switch = bs_grp_icon2:switch("\v\f<helmet-safety>\r  Safe Head"):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
-- Smart mode (hysteria): geometric head-ratio trigger instead of the basic
-- jump/height check. Off = basic.
bs_safe_head_gear = bs_v595.switch:create()
bs_v595.smart = bs_safe_head_gear:switch(bs_fmt("smart mode"), false):depend({
	bs_v595.switch,
	true
})
bs_aa_general.safe_head = bs_v595
bs_v597 = {
	 select = bs_grp_icon2:switch("\v\f<shield-halved>\r  Force Defensive"):depend({
		bs_tab_sel,
		bs_tab_general
	}, {
		bs_sel_selector,
		bs_cfg_sel_main
	})
}
bs_v606 = bs_v597.select:create()
bs_v597.activate = bs_v606:combo(bs_fmt("activate"), {
	"always",
	"conditions"
}):depend({
	bs_v597.select,
	true
})
bs_v597.conditions = bs_v606:selectable(bs_fmt("conditions"), {
	"standing",
	"running",
	"air",
	"air crouching",
	"crouching",
	"sneaking",
	"slowwalk",
	"quickpeek"
}):depend({
	bs_v597.select,
	true
}, {
	bs_v597.activate,
	"conditions"
})
bs_v597.events = bs_v606:selectable(bs_fmt("events"), {
		"weapon switch",
		"weapon reload",
		"on peek"
	}):depend({
		bs_v597.select,
		true
	})
bs_v597.additions_normal = bs_v606:selectable(bs_fmt("additions"), {
	"ignore grenade"
}):depend({
	bs_v597.select,
	true
})
bs_v597.hide_shots = bs_v606:combo(bs_fmt("hide shots"), {
	"favor fire rate",
	"favor fake lag",
	"break lc"
}):depend({
	bs_v597.select,
	true
})
bs_aa_general.break_lc = bs_v597
bs_v597.air_exploit = bs_grp_icon2:switch("\v\f<bug>\r  Air Exploit (Lag Comp)"):depend({
	bs_tab_sel,
	bs_tab_general
}, {
	bs_sel_selector,
	bs_cfg_sel_main
})
bs_v597_air_gear = bs_v597.air_exploit:create()
bs_v597.air_mode = bs_v597_air_gear:combo(bs_fmt("mode"), {
	"forward track",
	"back track"
}, "forward track"):depend({
	bs_v597.air_exploit,
	true
})
bs_v605 = {}
bs_v616 = bs_pui.create(bs_menu_icons.antiaim, " \n", 2):depend({
	bs_tab_sel,
	bs_tab_general
}, {
	bs_sel_selector,
	bs_cfg_sel_config
})
bs_v605.list = bs_v616:list("\n", {})
bs_v605.name = bs_v616:input("config name", "")
bs_v605.tabs = bs_v616:listable("\aA0A0A0FFtabs", {
	"\f<shield-halved>\r  anti-aim",
	"    \f<caret-right>\r  general",
	"    \f<caret-right>\r  builder",
	"    \f<caret-right>\r  defensive",
	"\f<eye>\r  visuals",
	"    \f<caret-right>\r  general",
	"    \f<caret-right>\r  ui",
	"\f<gears>\r  misc"
})

bs_v605.tabs:visibility(false)

bs_v605.load = bs_v616:button("  \v\f<toggle-on>\r  load  ", nil, true)
bs_v605.save = bs_v616:button("  \v\f<floppy-disk>\r  save  ", nil, true)
bs_v605.create = bs_v616:button("  \v\f<plus>\r  create  ", nil, true)
bs_v605.delete = bs_v616:button("  \aFF4D4DFF\f<trash-xmark>\r  delete  ", nil, true)
bs_v605.import = bs_v616:button("  \f<download>\r  import  ", nil, true)
bs_v605.export = bs_v616:button("  \f<file-export>\r  export  ", nil, true)
bs_v605.cancel = bs_v616:button("        \aDB6361FF\f<xmark>\r  cancel        ", nil, true)

bs_v605.cancel:visibility(false)

bs_v605.confirm = bs_v616:button("       \v\f<check>\r  confirm       ", nil, true)

bs_v605.confirm:visibility(false)

bs_v605.information = {
	creator = {
		name = function()
			return
		end
	}
}
bs_aa_general.presets = bs_v605
bs_menu.info.presets = bs_v605
bs_antiaim_menu.general = bs_aa_general
bs_v543 = {}
	bs_v551 = bs_ui_antiaim:list("\v\f<hammer>\r  Builder State", bs_states.states):depend({
	bs_tab_sel,
	bs_tab_builder
})
bs_antiaim_menu.configure = {
	state = bs_v551
}
	bs_v557 = bs_grp_icon2:label("\v\f<sliders>\r  State Settings"):depend({
	bs_tab_sel,
	bs_tab_builder
})
bs_v566 = bs_antiaim_menu.general.break_lc
bs_v570 = {}

for iter_0_3, iter_0_4 in ipairs(bs_states.states) do
	bs_v570[iter_0_4] = {}
	local bs_abf_phases = bs_v570[iter_0_4]
	bs_abf_phases.state_label = bs_grp_icon2:label(("\aA0A0A0FFcurrently editing: \aFFFFFFFF%s"):format(iter_0_4)):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	})
	bs_abf_phases.allow_state = bs_grp_icon2:switch(bs_fmt("enable state"), true):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	})
	bs_abf_phases.yaw = bs_grp_icon2:label(bs_fmt("yaw mode")):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.allow_state,
		true
	})
	bs_v633 = bs_abf_phases.yaw:create()
	bs_abf_phases.yaw_mode = bs_v633:combo(bs_fmt("mode"), {
		"Real Angle",
		"Gravity Yaw"
	}, "Real Angle")
	bs_abf_phases.async_yaw = bs_v633:switch(bs_fmt("async yaw"), false):depend({
		bs_abf_phases.yaw_mode,
		"Real Angle"
	})
	bs_abf_phases.async_yaw_mode = bs_v633:combo(bs_fmt("async mode"), { "Exploit/HS", "Always" }, "Exploit/HS"):depend({
		bs_abf_phases.async_yaw,
		true
	})
	bs_abf_phases.async_swap_mode = bs_v633:combo(bs_fmt("async swap"), { "Tickbase", "Send Tick", "Both" }, "Tickbase"):depend({
		bs_abf_phases.async_yaw,
		true
	})
	bs_abf_phases.yaw_left = bs_v633:slider(bs_fmt("real left"), -180, 180, 0):depend({
		bs_abf_phases.yaw_mode,
		"Real Angle"
	}, {
		bs_abf_phases.async_yaw,
		false
	})
	bs_abf_phases.yaw_right = bs_v633:slider(bs_fmt("real right"), -180, 180, 0):depend({
		bs_abf_phases.yaw_mode,
		"Real Angle"
	}, {
		bs_abf_phases.async_yaw,
		false
	})
	bs_abf_phases.async_yaw_left = bs_v633:slider(bs_fmt("async left"), -180, 180, 0):depend({
		bs_abf_phases.async_yaw,
		true
	})
	bs_abf_phases.async_yaw_right = bs_v633:slider(bs_fmt("async right"), -180, 180, 0):depend({
		bs_abf_phases.async_yaw,
		true
	})
	bs_abf_phases.gravity_yaw_left = bs_v633:slider(bs_fmt("gravity left"), -180, 180, 0):depend({
		bs_abf_phases.yaw_mode,
		"Gravity Yaw"
	})
	bs_abf_phases.gravity_yaw_right = bs_v633:slider(bs_fmt("gravity right"), -180, 180, 0):depend({
		bs_abf_phases.yaw_mode,
		"Gravity Yaw"
	})

	local gravity_sequence = {
		"right",
		"left",
		"left",
		"left",
		"right",
		"left",
		"right",
		"right"
	}

	for gravity_step = 1, 8 do
		bs_abf_phases["gravity_step_" .. gravity_step] = bs_v633:combo(bs_fmt(("gravity %d"):format(gravity_step)), {
			"Left",
			"Right"
		}):depend({
			bs_abf_phases.yaw_mode,
			"Gravity Yaw"
		})
		bs_abf_phases["gravity_step_" .. gravity_step]:set(gravity_sequence[gravity_step] == "left" and "Left" or "Right")
	end

	bs_abf_phases.gravity_yaw_enabled = bs_v633:switch(bs_fmt("enabled"), true):depend({
		bs_abf_phases.yaw_mode,
		"Gravity Yaw"
	})
	bs_abf_phases.gravity_speed = bs_v633:slider(bs_fmt("speed (ticks/step)"), 1, 50, 1, 1):depend({
		bs_abf_phases.yaw_mode,
		"Gravity Yaw"
	}, {
		bs_abf_phases.gravity_yaw_enabled,
		true
	})
	bs_abf_phases.gravity_direction = bs_v633:combo(bs_fmt("direction"), {
		"Auto (sequence)",
		"Manual: Left",
		"Manual: Right",
		"Invert sequence"
	}, "Auto (sequence)"):depend({
		bs_abf_phases.yaw_mode,
		"Gravity Yaw"
	}, {
		bs_abf_phases.gravity_yaw_enabled,
		true
	})
	bs_abf_phases.gravity_use_limits = bs_v633:switch(bs_fmt("use body yaw limits"), true):depend({
		bs_abf_phases.yaw_mode,
		"Gravity Yaw"
	}, {
		bs_abf_phases.gravity_yaw_enabled,
		true
	})

	bs_abf_phases.delay_seq_sliders = {}
	bs_abf_phases.delay_seq_idx = 0
	bs_abf_phases.yaw_base = bs_grp_icon2:combo(bs_fmt("base"), {
		"at target",
		"local view"
	}, "at target"):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.allow_state,
		true
	})
	bs_abf_phases.modifier = bs_grp_icon2:combo(bs_fmt("offset"), {
		"disabled",
		"center",
		"offset",
		"random",
		"spin",
		"3-way",
		"5-way",
		"skitter",
		"chaos",
		"dual"
	}):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.allow_state,
		true
	})
	bs_v632 = bs_abf_phases.modifier:create()
	bs_abf_phases.randomize = bs_v632:switch(bs_fmt("randomize"), false):depend({
		bs_v551, 
		iter_0_3 
	}, { 
		bs_abf_phases.modifier, 
		"disabled", 
		true 
	})
	bs_abf_phases.modifier_mode = bs_v632:combo(bs_fmt("distribution"), { 
		"uniform", 
		"weighted", 
		"pulse", 
		"custom" 
	}):depend({ 
		bs_v551, 
		iter_0_3 
	}, { 
		bs_abf_phases.modifier, 
		"disabled", 
		true 
	}, { 
		bs_abf_phases.randomize, 
		true 
	})
	bs_abf_phases.min = bs_v632:slider(bs_fmt("min"), -180, 180, -60):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"uniform"
	})
	bs_abf_phases.max = bs_v632:slider(bs_fmt("max"), -180, 180, 60):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"uniform"
	})
	bs_abf_phases.modifier_weight_center = bs_v632:slider(bs_fmt("center bias"), 0, 100, 50, 1, "%"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"weighted"
	})
	bs_abf_phases.modifier_weight_spread = bs_v632:slider(bs_fmt("spread"), 5, 180, 60, 1, "°"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"weighted"
	})
	bs_abf_phases.modifier_pulse_a = bs_v632:slider(bs_fmt("value a"), -180, 180, -60):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"pulse"
	})
	bs_abf_phases.modifier_pulse_b = bs_v632:slider(bs_fmt("value b"), -180, 180, 60):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"pulse"
	})
	bs_abf_phases.modifier_pulse_rate = bs_v632:slider(bs_fmt("pulse rate"), 1, 22, 8, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"pulse"
	})
	bs_abf_phases.modifier_custom_sliders = bs_v632:slider(bs_fmt("steps"), 2, 6, 2):depend({ 
		bs_v551, 
		iter_0_3 
	}, { 
		bs_abf_phases.modifier, 
		"disabled", 
		true 
	}, { 
		bs_abf_phases.randomize, 
		true 
	}, { 
		bs_abf_phases.modifier_mode, 
		"custom" 
	})

	for iter_0_5 = 1, 6 do 
		bs_abf_phases["modifier_sliders_" .. iter_0_5] = bs_v632:slider(bs_fmt(("step %d"):format(iter_0_5)), -180, 180, 0):depend({ 
			bs_v551, 
			iter_0_3 
		}, { 
			bs_abf_phases.modifier, 
			"disabled", 
			true 
		}, { 
			bs_abf_phases.randomize, 
			true 
		}, { 
			bs_abf_phases.modifier_mode, 
			"custom" 
		}, { 
			bs_abf_phases.modifier_custom_sliders, 
			function() 
				return iter_0_5 <= 2 or bs_abf_phases.modifier_custom_sliders.value >= iter_0_5
			end 
		}) 
	end 

	bs_abf_phases.modifier_custom_random = bs_v632:button(bs_fmt("randomize custom"), function()
		local random_count = math.random(2, 6)
		bs_abf_phases.modifier_custom_sliders:set(random_count)

		for i = 1, random_count do
			local custom_slider = bs_abf_phases["modifier_sliders_" .. i]

			if custom_slider then
				custom_slider:set(math.random(-60, 60))
			end
		end

		-- Also randomize desync degrees (never below 35).
		local desync_deg = math.random(35, 60)
		if bs_abf_phases.fake_limit_static then bs_abf_phases.fake_limit_static:set(desync_deg) end
		if bs_abf_phases.fake_limit_random then bs_abf_phases.fake_limit_random:set(desync_deg) end
		if bs_abf_phases.left_limit then bs_abf_phases.left_limit:set(desync_deg) end
		if bs_abf_phases.right_limit then bs_abf_phases.right_limit:set(desync_deg) end
	end):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"disabled",
		true
	}, {
		bs_abf_phases.randomize,
		true
	}, {
		bs_abf_phases.modifier_mode,
		"custom"
	})

	bs_abf_phases.modifier_offset = bs_v632:slider(bs_fmt("offset"), -180, 180, 0):depend({ 
		bs_v551, 
		iter_0_3 
	}, { 
		bs_abf_phases.modifier, 
		"disabled", 
		true 
	}, { 
		bs_abf_phases.randomize, 
		false 
	}, { 
		bs_abf_phases.modifier,
		function()
			local v = bs_abf_phases.modifier.value
			return v ~= "dual" and v ~= "skitter" and v ~= "chaos"
		end
	})
	bs_abf_phases.skitter_deg = bs_v632:slider(bs_fmt("degree"), 1, 90, 45, 1, "°"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"skitter"
	})
	bs_abf_phases.dual_left_off = bs_v632:slider(bs_fmt("left offset"), -180, 180, -60, 1, "°"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"dual"
	})
	bs_abf_phases.dual_right_off = bs_v632:slider(bs_fmt("right offset"), -180, 180, 60, 1, "°"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"dual"
	})
	bs_abf_phases.dual_distribution = bs_v632:combo(bs_fmt("distribution"), {
		"alternate",
		"random",
		"pulse"
	}):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"dual"
	})
	bs_abf_phases.dual_rate = bs_v632:slider(bs_fmt("rate"), 1, 16, 2, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"dual"
	}, {
		bs_abf_phases.dual_distribution,
		function()
			return bs_abf_phases.dual_distribution.value ~= "random"
		end
	})
	bs_abf_phases.dual_rate_b = bs_v632:slider(bs_fmt("rate b"), 1, 16, 4, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"dual"
	}, {
		bs_abf_phases.dual_distribution,
		"pulse"
	})
	bs_abf_phases.chaos_range = bs_v632:slider(bs_fmt("range"), 1, 180, 60, 1, "°"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.modifier,
		"chaos"
	})
	bs_abf_phases.body_yaw = bs_grp_icon2:switch(bs_fmt("fake yaw"), false):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.allow_state,
		true
	})
	bs_v631 = bs_abf_phases.body_yaw:create()
	bs_abf_phases.body_yaw_mode = bs_v631:combo(bs_fmt("mode"), {
		"static",
		"jitter",
		"random"
	}):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	})
	bs_abf_phases.body_yaw_delay_mode = bs_v631:combo(bs_fmt("delay mode"), {
		"static",
		"random",
		"sequence"
	}):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	})
	bs_abf_phases.body_yaw_delay = bs_v631:slider(bs_fmt("delay"), 0, 20, 0, 1, function(arg_54_0)
		if arg_54_0 == 0 then
			return "Off"
		end

		return arg_54_0 .. (arg_54_0 == 1 and " tick" or " ticks")
	end):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_delay_mode,
		"static"
	})
	bs_abf_phases.body_yaw_delay_random_min = bs_v631:slider(bs_fmt("min"), 1, 20, 2, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_delay_mode,
		"random"
	})
	bs_abf_phases.body_yaw_delay_random_max = bs_v631:slider(bs_fmt("max"), 1, 20, 6, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_delay_mode,
		"random"
	})
	bs_abf_phases.body_yaw_delay_seq_count = bs_v631:slider(bs_fmt("steps"), 2, 10, 3):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_delay_mode,
		"sequence"
	})
	bs_abf_phases.body_yaw_delay_seq_sliders = {}

	for iter_0_6 = 1, 10 do
		local sequence_index = iter_0_6
		local sequence_key = "body_yaw_delay_seq_s" .. sequence_index

		bs_abf_phases[sequence_key] = bs_v631:slider(bs_fmt("step " .. sequence_index), 0, 20, 4, 1, function(arg_55_0)
			if arg_55_0 == 0 then
				return "Off"
			end

			return arg_55_0 .. "t"
		end):depend({
			bs_v551,
			iter_0_3
		}, {
			bs_abf_phases.body_yaw,
			true
		}, {
			bs_abf_phases.body_yaw_delay_mode,
			"sequence"
		}, {
			bs_abf_phases.body_yaw_delay_seq_count,
			function()
				return bs_abf_phases.body_yaw_delay_seq_count:get() >= sequence_index
			end
		})
		bs_abf_phases.body_yaw_delay_seq_sliders[sequence_index] = bs_abf_phases[sequence_key]
	end

	bs_abf_phases.body_yaw_delay_seq_random = bs_v631:button(bs_fmt("randomize sequence"), function()
		local random_count = math.random(2, 10)
		bs_abf_phases.body_yaw_delay_seq_count:set(random_count)

		for i = 1, random_count do
			local seq_slider = bs_abf_phases.body_yaw_delay_seq_sliders[i]

			if seq_slider then
				seq_slider:set(math.random(0, 20))
			end
		end
	end):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_delay_mode,
		"sequence"
	})

	bs_abf_phases.fake_limit_static = bs_v631:slider(bs_fmt("limit"), -60, 60, 60):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_mode,
		"static"
	})
	bs_abf_phases.fake_limit_random = bs_v631:slider(bs_fmt("limit"), 0, 60, 30):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_mode,
		"random"
	})
	bs_abf_phases.left_limit = bs_v631:slider(bs_fmt("left"), 0, 60, 60):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_mode,
		"jitter"
	})
	bs_abf_phases.right_limit = bs_v631:slider(bs_fmt("right"), 0, 60, 60):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	}, {
		bs_abf_phases.body_yaw_mode,
		"jitter"
	})
	bs_abf_phases.freestand_peek = bs_v631:combo(bs_fmt("freestand"), {
		"off",
		"peek fake",
		"peek real"
	}, "off"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.body_yaw,
		true
	})
	bs_abf_phases.choke = bs_grp_icon2:combo(bs_fmt("tickbase"), {
		"default",
		"custom"
	}):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.allow_state,
		true
	})
	bs_v630 = bs_abf_phases.choke:create()
	bs_abf_phases.random_choke = bs_v630:switch(bs_fmt("randomize"), false):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.choke,
		"custom"
	})
	bs_abf_phases.choke_slider = bs_v630:slider(bs_fmt("ticks"), 2, 22, 16, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.choke,
		"custom"
	}, {
		bs_abf_phases.random_choke,
		false
	})
	bs_abf_phases.choke_method = bs_v630:combo(bs_fmt("random mode"), {
		"range",
		"sequence"
	}):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.choke,
		"custom"
	}, {
		bs_abf_phases.random_choke,
		true
	})
	bs_abf_phases.choke_from = bs_v630:slider(bs_fmt("min"), 1, 22, 8, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.choke,
		"custom"
	}, {
		bs_abf_phases.random_choke,
		true
	}, {
		bs_abf_phases.choke_method,
		"range"
	})
	bs_abf_phases.choke_to = bs_v630:slider(bs_fmt("max"), 1, 22, 16, 1, "t"):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.choke,
		"custom"
	}, {
		bs_abf_phases.random_choke,
		true
	}, {
		bs_abf_phases.choke_method,
		"range"
	})
	bs_abf_phases.choke_sliders = bs_v630:slider(bs_fmt("steps"), 2, 6, 2):depend({
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.choke,
		"custom"
	}, {
		bs_abf_phases.random_choke,
		true
	}, {
		bs_abf_phases.choke_method,
		"sequence"
	})

	for iter_0_7 = 1, 6 do
		bs_abf_phases["choke1_" .. iter_0_7] = bs_v630:slider(bs_fmt(("step %d"):format(iter_0_7)), 2, 22, 4, 1, "t"):depend({
			bs_v551,
			iter_0_3
		}, {
			bs_abf_phases.choke,
			"custom"
		}, {
			bs_abf_phases.random_choke,
			true
		}, {
			bs_abf_phases.choke_method,
			"sequence"
		}, {
			bs_abf_phases.choke_sliders,
			function()
				return iter_0_7 <= 2 or bs_abf_phases.choke_sliders.value >= iter_0_7
			end
		})
	end

	bs_abf_phases.anti_bruteforce = bs_grp_icon2:switch(bs_fmt("anti bruteforce"), false):depend({
		bs_tab_sel,
		bs_tab_builder
	}, {
		bs_v551,
		iter_0_3
	}, {
		bs_abf_phases.allow_state,
		true
	})
	bs_v629 = bs_abf_phases.anti_bruteforce:create()
	bs_abf_phases.abf_reset_timer = bs_v629:slider(bs_fmt("reset"), 1, 10, 3, 1, "s"):depend({
		bs_abf_phases.anti_bruteforce,
		true
	})
	bs_abf_phases.abf_trigger = bs_v629:combo(bs_fmt("trigger"), {
		"miss",
		"hit",
		"both"
	}, "miss"):depend({
		bs_abf_phases.anti_bruteforce,
		true
	})
	bs_abf_phases.abf_notify = bs_v629:switch(bs_fmt("notify"), true):depend({
		bs_abf_phases.anti_bruteforce,
		true
	})
	bs_abf_phases.abf_on_shot = bs_v629:switch(bs_fmt("on shot"), false):depend({
		bs_abf_phases.anti_bruteforce,
		true
	})
	bs_abf_phases.abf_phases = {}
	bs_abf_phases.abf_phase_n = 1
	bs_abf_phases.abf_phase_sel = bs_v629:combo(bs_fmt("phase"), { 
		"1" 
	}, "1"):depend({ 
		bs_abf_phases.anti_bruteforce, 
		true 
	}) 

	local function bs_v646() 
		local var_58_0 = {} 

		for iter_58_0 = 1, bs_abf_phases.abf_phase_n do 
			var_58_0[iter_58_0] = tostring(iter_58_0) 
		end 

		bs_abf_phases.abf_phase_sel:update(var_58_0) 
		local current = bs_abf_phases.abf_phase_sel:get()
		local cnum = tonumber(current)
		if not cnum or cnum < 1 or cnum > bs_abf_phases.abf_phase_n then
			bs_abf_phases.abf_phase_sel:set(tostring(bs_abf_phases.abf_phase_n))
		end
	end 

	bs_v629:button(bs_fmt("add phase"), function() 
		if bs_abf_phases.abf_phase_n < 10 then 
			bs_abf_phases.abf_phase_n = bs_abf_phases.abf_phase_n + 1 

			bs_v646() 
			bs_abf_phases.abf_phase_sel:set(tostring(bs_abf_phases.abf_phase_n))
		end 
	end):depend({ 
		bs_abf_phases.anti_bruteforce, 
		true 
	}) 
	bs_v629:button(bs_fmt("remove phase"), function() 
		if bs_abf_phases.abf_phase_n > 1 then 
			bs_abf_phases.abf_phase_n = bs_abf_phases.abf_phase_n - 1 

			bs_v646() 
			bs_abf_phases.abf_phase_sel:set(tostring(bs_abf_phases.abf_phase_n))
		end 
	end, true):depend({ 
		bs_abf_phases.anti_bruteforce, 
		true 
	}) 

	for iter_0_8 = 1, 10 do 
		local bs_v688 = iter_0_8 
		local bs_v697 = bs_abf_phases.abf_phases[bs_v688] or {} 

		local function bs_v708() 
			return bs_abf_phases.abf_phase_n >= bs_v688 and bs_abf_phases.abf_phase_sel:get() == tostring(bs_v688) 
		end 

		if not bs_v697.rand_min then
			if bs_v688 == 1 then 
				bs_v697.rand_min = bs_v629:slider(bs_fmt("randomization 1"), -40, 40, 0):depend({ 
					bs_abf_phases.anti_bruteforce, 
					true 
				}, { 
					bs_abf_phases.abf_phase_sel, 
					"1" 
				}) 
				bs_v697.rand_max = bs_v629:slider(bs_fmt("randomization 2"), -40, 40, 0):depend({ 
					bs_abf_phases.anti_bruteforce, 
					true 
				}, { 
					bs_abf_phases.abf_phase_sel, 
					"1" 
				}) 
			else 
				bs_v697.rand_min = bs_v629:slider(bs_fmt("randomization 1"), -40, 40, 0):depend({ 
					bs_abf_phases.anti_bruteforce, 
					true 
				}, { 
					bs_abf_phases.abf_phase_sel, 
					function() 
						return bs_v708() 
					end 
				}) 
				bs_v697.rand_max = bs_v629:slider(bs_fmt("randomization 2"), -40, 40, 0):depend({ 
					bs_abf_phases.anti_bruteforce, 
					true 
				}, { 
					bs_abf_phases.abf_phase_sel, 
					function() 
						return bs_v708() 
					end 
				}) 
			end
		end

		bs_abf_phases.abf_phases[bs_v688] = bs_v697 
	end 

	bs_v570[iter_0_4] = bs_abf_phases
end

bs_v543.builder = bs_v570
bs_v584 = {
	switch = bs_antiaim_menu.general.freestanding.switch
}
bs_body_fs_switch = bs_v584.switch:create()
bs_v584.prefer_manual = bs_body_fs_switch:switch(bs_fmt("prefer manual"))
bs_v584.body_fs = bs_body_fs_switch:switch(bs_fmt("body freestanding"))
bs_v584.yaw_mod = bs_body_fs_switch:switch(bs_fmt("disable yaw modifiers"))
bs_v584.force_static = bs_body_fs_switch:switch(bs_fmt("force static"))
bs_v584.disablers = bs_body_fs_switch:selectable(bs_fmt("disablers"), {
	"air",
	"crouch",
	"slowwalk",
	"move"
})
bs_v543.freestanding = bs_v584
bs_antiaim_menu.angles = bs_v543
bs_v550 = {
	settings = {}
}
bs_v556 = {}

for iter_0_9, iter_0_10 in ipairs(bs_states.states) do
	if iter_0_10 ~= "legit aa" and iter_0_10 ~= "fakelag" then
		bs_v556[#bs_v556 + 1] = iter_0_10
	end
end

bs_v556[#bs_v556 + 1] = "safe head"
	bs_v556[#bs_v556 + 1] = "freestanding"
	bs_v556[#bs_v556 + 1] = "game events"
	bs_v565 = bs_ui_antiaim:list("\v\f<shield>\r  Defensive State", bs_v556):depend({
	bs_tab_sel,
	bs_tab_defensive
})
bs_v550.state_selector = bs_v565
bs_v550.active_on = bs_ui_antiaim:selectable(bs_fmt("active on"), {
	"doubletap",
	"hideshots"
}):depend({
	bs_tab_sel,
	bs_tab_defensive
})
	bs_v569 = bs_grp_icon2:label("\v\f<sliders>\r  State Settings"):depend({
	bs_tab_sel,
	bs_tab_defensive
})

function bs_v583(arg_64_0, arg_64_1)
		bs_v2028 = {}
		bs_v550.settings[arg_64_0] = bs_v2028



	bs_v2028.state_label = bs_grp_icon2:label(("\aA0A0A0FFcurrently editing: \aFFFFFFFF%s"):format(arg_64_0)):depend({
			bs_tab_sel,
			bs_tab_defensive
		}, {
			bs_v565,
			arg_64_1
		})
		bs_v2028.fe = bs_grp_icon2:switch(bs_fmt("flick exploit"), false):depend({
		bs_tab_sel,
		bs_tab_defensive
	}, {
		bs_v565,
		arg_64_1
	})
	bs_v2032 = bs_v2028.fe:create()
	bs_v2028.fe_alt = bs_v2032:switch(bs_fmt("safe mode"), false):depend({
		bs_v2028.fe,
		true
	})
	bs_v2028.fe_peek = bs_v2032:switch(bs_fmt("auto fake"), false):depend({
		bs_v2028.fe,
		true
	})
	bs_v2028.fe_snap_delay = bs_v2032:slider(bs_fmt("snap delay"), 0, 14, 3, 1, "t"):depend({
		bs_v2028.fe,
		true
	})
	bs_v2028.enable = bs_grp_icon2:switch(bs_fmt("enable"), false):depend({
		bs_tab_sel,
		bs_tab_defensive
	}, {
		bs_v565,
		arg_64_1
	}, {
		bs_v597.events,
		function()
			return bs_v597.events:get("weapon switch") or bs_v597.events:get("weapon reload") or bs_v597.events:get("on peek")
		end
	})
	bs_v2028.pitch_mode = bs_grp_icon2:combo(bs_fmt("pitch"), {
		"off",
		"down",
		"up",
		"random",
		"custom",
		"bluesense",
		"semi-up",
		"semi-down",
		"dynamic",
		"oscillate"
	}):depend({
		bs_tab_sel,
		bs_tab_defensive
	}, {
		bs_v565,
		arg_64_1
	}, {
		bs_v2028.enable,
		true
	})
	bs_v2031 = bs_v2028.pitch_mode:create()
	bs_v2028.pitch = bs_v2031:slider(bs_fmt("value"), -89, 89, 89):depend({
		bs_v2028.pitch_mode,
		"custom"
	})
	bs_v2028.dyn_pitch_min = bs_v2031:slider(bs_fmt("min"), -89, 89, -89):depend({
		bs_v2028.pitch_mode,
		"dynamic"
	})
	bs_v2028.dyn_pitch_max = bs_v2031:slider(bs_fmt("max"), -89, 89, 89):depend({
		bs_v2028.pitch_mode,
		"dynamic"
	})
	bs_v2028.dyn_pitch_spd = bs_v2031:slider(bs_fmt("rate"), 1, 200, 60, 1, "t"):depend({
		bs_v2028.pitch_mode,
		"dynamic"
	})
	bs_v2028.dyn_pitch_mode = bs_v2031:combo(bs_fmt("wave"), {
		"sine",
		"triangle",
		"step",
		"bounce"
	}, "sine"):depend({
		bs_v2028.pitch_mode,
		"dynamic"
	})
	bs_v2028.dyn_pitch_rand = bs_v2031:slider(bs_fmt("noise"), 0, 30, 0, 1, "°"):depend({
		bs_v2028.pitch_mode,
		"dynamic"
	})
	bs_v2028.osc_pitch_a = bs_v2031:slider(bs_fmt("pos a"), -89, 89, -89):depend({
		bs_v2028.pitch_mode,
		"oscillate"
	})
	bs_v2028.osc_pitch_b = bs_v2031:slider(bs_fmt("pos b"), -89, 89, 89):depend({
		bs_v2028.pitch_mode,
		"oscillate"
	})
	bs_v2028.osc_pitch_rate = bs_v2031:slider(bs_fmt("switch rate"), 1, 22, 6, 1, "t"):depend({
		bs_v2028.pitch_mode,
		"oscillate"
	})
	bs_v2028.osc_pitch_rand = bs_v2031:slider(bs_fmt("noise"), 0, 20, 0, 1, "t"):depend({
		bs_v2028.pitch_mode,
		"oscillate"
	})
	bs_v2028.yaw_mode = bs_grp_icon2:combo(bs_fmt("yaw"), {
		"off",
		"static",
		"flip",
		"sideways",
		"random",
		"opposite",
		"spin",
		"dynamic",
		"jitter",
		"sweep"
	}):depend({
		bs_tab_sel,
		bs_tab_defensive
	}, {
		bs_v565,
		arg_64_1
	}, {
		bs_v2028.enable,
		true
	})
	bs_v2030 = bs_v2028.yaw_mode:create()
	bs_v2028.yaw = bs_v2030:slider(bs_fmt("offset"), -180, 180, 0):depend({
		bs_v2028.yaw_mode,
		"static"
	})
	bs_v2028.yaw_lr_left = bs_v2030:slider(bs_fmt("left"), -60, 60, 0):depend({
		bs_v2028.yaw_mode,
		"flip"
	})
	bs_v2028.yaw_lr_right = bs_v2030:slider(bs_fmt("right"), -60, 60, 0):depend({
		bs_v2028.yaw_mode,
		"flip"
	})
	bs_v2028.yaw_lr_dt = bs_v2030:slider(bs_fmt("interval"), 1, 22, 6, 1, "t"):depend({
		bs_v2028.yaw_mode,
		"flip"
	})
	bs_v2028.yaw_lr_rand = bs_v2030:slider(bs_fmt("noise"), 0, 60, 0, 1, "°"):depend({
		bs_v2028.yaw_mode,
		"flip"
	})
	bs_v2028.def_flip_adaptive = bs_v2030:switch(bs_fmt("adaptive rate"), false):depend({
		bs_v2028.yaw_mode,
		"flip"
	})
	bs_v2028.def_flip_adp_var = bs_v2030:slider(bs_fmt("drift"), 1, 8, 3, 1, "t"):depend({
		bs_v2028.yaw_mode,
		"flip"
	}, {
		bs_v2028.def_flip_adaptive,
		true
	})
	bs_v2028.yaw_spin_from = bs_v2030:slider(bs_fmt("from"), -180, 180, -180):depend({
		bs_v2028.yaw_mode,
		"spin"
	})
	bs_v2028.yaw_spin_to = bs_v2030:slider(bs_fmt("to"), -180, 180, 180):depend({
		bs_v2028.yaw_mode,
		"spin"
	})
	bs_v2028.yaw_spin_spd = bs_v2030:slider(bs_fmt("speed"), 1, 30, 1, 1, "t"):depend({
		bs_v2028.yaw_mode,
		"spin"
	})
	bs_v2028.yaw_spin_rand = bs_v2030:slider(bs_fmt("noise"), 0, 180, 33, 1, "°"):depend({
		bs_v2028.yaw_mode,
		"spin"
	})
	bs_v2028.dyn_yaw_min = bs_v2030:slider(bs_fmt("min"), -180, 180, -180):depend({
		bs_v2028.yaw_mode,
		"dynamic"
	})
	bs_v2028.dyn_yaw_max = bs_v2030:slider(bs_fmt("max"), -180, 180, 180):depend({
		bs_v2028.yaw_mode,
		"dynamic"
	})
	bs_v2028.dyn_yaw_spd = bs_v2030:slider(bs_fmt("rate"), 1, 200, 60, 1, "t"):depend({
		bs_v2028.yaw_mode,
		"dynamic"
	})
	bs_v2028.dyn_yaw_mode = bs_v2030:combo(bs_fmt("wave"), {
		"sine",
		"triangle",
		"step",
		"bounce"
	}, "sine"):depend({
		bs_v2028.yaw_mode,
		"dynamic"
	})
	bs_v2028.dyn_yaw_rand = bs_v2030:slider(bs_fmt("noise"), 0, 45, 0, 1, "°"):depend({
		bs_v2028.yaw_mode,
		"dynamic"
	})
	bs_v2028.def_jitter_base = bs_v2030:slider(bs_fmt("center"), -180, 180, 0):depend({
		bs_v2028.yaw_mode,
		"jitter"
	})
	bs_v2028.def_jitter_range = bs_v2030:slider(bs_fmt("range"), 0, 90, 40, 1, "°"):depend({
		bs_v2028.yaw_mode,
		"jitter"
	})
	bs_v2028.def_jitter_speed = bs_v2030:slider(bs_fmt("speed"), 1, 14, 3, 1, "t"):depend({
		bs_v2028.yaw_mode,
		"jitter"
	})
	bs_v2028.def_jitter_style = bs_v2030:combo(bs_fmt("waveform"), {
		"sine",
		"triangle",
		"bounce",
		"step",
		"noise"
	}):depend({
		bs_v2028.yaw_mode,
		"jitter"
	})
	bs_v2028.def_jitter_phase = bs_v2030:slider(bs_fmt("phase"), 0, 359, 0, 1, "°"):depend({
		bs_v2028.yaw_mode,
		"jitter"
	})
	bs_v2028.sweep_from = bs_v2030:slider(bs_fmt("from"), -180, 180, -90):depend({
		bs_v2028.yaw_mode,
		"sweep"
	})
	bs_v2028.sweep_to = bs_v2030:slider(bs_fmt("to"), -180, 180, 90):depend({
		bs_v2028.yaw_mode,
		"sweep"
	})
	bs_v2028.sweep_rate = bs_v2030:slider(bs_fmt("rate"), 1, 22, 6, 1, "t"):depend({
		bs_v2028.yaw_mode,
		"sweep"
	})
	bs_v2028.sweep_hold = bs_v2030:slider(bs_fmt("hold"), 0, 10, 2, 1, "t"):depend({
		bs_v2028.yaw_mode,
		"sweep"
	})
	bs_v2028.sweep_rand = bs_v2030:slider(bs_fmt("noise"), 0, 40, 0, 1, "°"):depend({
		bs_v2028.yaw_mode,
		"sweep"
	})
	bs_v2028.activation_mode = bs_grp_icon2:combo(bs_fmt("activation"), {
		"always",
		"hittable only"
	}):depend({
		bs_tab_sel,
		bs_tab_defensive
	}, {
		bs_v565,
		arg_64_1
	}, {
		bs_v2028.enable,
		true
	})
	bs_v2028.def_abf = bs_grp_icon2:switch(bs_fmt("anti bruteforce"), false):depend({
		bs_tab_sel,
		bs_tab_defensive
	}, {
		bs_v565,
		arg_64_1
	}, {
		bs_v2028.enable,
		true
	})
	bs_v2029 = bs_v2028.def_abf:create()
	bs_v2028.def_abf_mode = bs_v2029:combo(bs_fmt("mode"), {
		"flip yaw",
		"flip pitch",
		"random yaw"
	}):depend({
		bs_v2028.def_abf,
		true
	})
	bs_v2028.def_abf_trigger = bs_v2029:combo(bs_fmt("trigger"), {
		"miss",
		"hit",
		"both"
	}, "miss"):depend({
		bs_v2028.def_abf,
		true
	})
	bs_v2028.def_abf_reset = bs_v2029:slider(bs_fmt("reset"), 1, 10, 3, 1, "s"):depend({
		bs_v2028.def_abf,
		true
	})
	bs_v2028.def_abf_notify = bs_v2029:switch(bs_fmt("notify"), true):depend({
		bs_v2028.def_abf,
		true
	})
end

for iter_0_11, iter_0_12 in ipairs(bs_v556) do
	bs_v583(iter_0_12, iter_0_11)
end

bs_antiaim_menu.defensive = bs_v550
bs_menu.antiaim = bs_antiaim_menu

bs_pui.create(bs_menu_icons.antiaim, "  ", 2):label("\v✦\r  \aFFFFFFFFbluesense \a444444FF— 2026")

bs_v538 = bs_pui.create(bs_menu_icons.visuals, "     ", 1)
bs_v542 = {
	"\f<sliders>\r  general",
	"\f<palette>\r  ui"
}
bs_v549 = 1
bs_v555 = 2
bs_v564 = bs_v538:list("", bs_v542)
bs_v576 = bs_pui.create(bs_menu_icons.visuals, "       ", 1)
bs_v582 = bs_pui.create(bs_menu_icons.visuals, "         ", 2)
bs_v590 = {}
bs_abf_group = {
	 switch = bs_v576:switch("\v\f<arrow-right-arrow-left>\r  Manual Arrows"):depend({
		bs_v564,
		bs_v549
	})
}
bs_v603 = bs_abf_group.switch:create()
bs_abf_group.color = bs_v603:color_picker(bs_fmt("color"), color(255, 255, 255, 255)):depend({
	bs_abf_group.switch,
	true
})
bs_abf_group.dynamic = bs_v603:switch(bs_fmt("dynamic mode"), false):depend({
	bs_abf_group.switch,
	true
})
bs_abf_group.style = bs_v603:combo(bs_fmt("style"), {
	"modern",
	"old"
}, "modern"):depend({
	bs_abf_group.switch,
	true
})
bs_abf_group.color_enemy = bs_v603:color_picker(bs_fmt("enemy side color"), color(255, 60, 60, 255)):depend({
	bs_abf_group.switch,
	true
}, {
	bs_abf_group.dynamic,
	true
})
bs_abf_group.color_opposite = bs_v603:color_picker(bs_fmt("opposite side color"), color(60, 60, 60, 200)):depend({
	bs_abf_group.switch,
	true
}, {
	bs_abf_group.dynamic,
	true
})
bs_v590.manual_arrows = bs_abf_group
bs_v602 = {
	 switch = bs_v576:switch("\v\f<expand>\r  Aspect Ratio"):depend({
		bs_v564,
		bs_v549
	})
}
bs_v604 = bs_v602.switch:create()
bs_v602.value = bs_v604:slider(bs_fmt("ratio"), 1, 200, 133, 0.01):depend({
	bs_v602.switch,
	true
})
bs_v615 = cvar.r_aspectratio

function bs_restore_aspect()
	bs_v615:float(bs_cvar_backup:get_original(bs_v615))
end

function bs_apply_aspect()
	if not bs_v602.switch:get() then
		bs_restore_aspect()

		return
	end

	bs_v615:float(bs_v602.value:get() * 0.01, true)
end

bs_v602.switch:set_callback(bs_apply_aspect, true)
bs_v602.value:set_callback(bs_apply_aspect)
events.shutdown(bs_restore_aspect)

bs_v590.aspect_ratio = bs_v602
bs_v612 = {
	 switch = bs_v582:switch("\v\f<chart-bar>\r  LC Indicator"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v614 = bs_v612.switch:create()
bs_v612.col_failed = bs_v614:color_picker("failed color", color(255, 64, 64, 255)):depend({
	bs_v612.switch,
	true
})
bs_v612.col_bad = bs_v614:color_picker("bad color", color(255, 175, 104, 255)):depend({
	bs_v612.switch,
	true
})
bs_v612.col_ok = bs_v614:color_picker("ok color", color(185, 185, 190, 255)):depend({
	bs_v612.switch,
	true
})
bs_v612.col_good = bs_v614:color_picker("good color", color(205, 236, 142, 255)):depend({
	bs_v612.switch,
	true
})
bs_v612.col_ideal = bs_v614:color_picker("ideal color", color(101, 213, 255, 255)):depend({
	bs_v612.switch,
	true
})
bs_v612.col_god = bs_v614:color_picker("amazing color", color(207, 145, 255, 255)):depend({
	bs_v612.switch,
	true
})
bs_v612.col_wt = bs_v614:color_picker("$$$ color", color(255, 215, 0, 255)):depend({
	bs_v612.switch,
	true
})
	bs_v612.glow = bs_v614:switch("Glow", true):depend({
	bs_v612.switch,
	true
})
	bs_v612.text_case = bs_v614:combo("Text Case", {
	"uppercase",
	"lowercase"
}, "uppercase"):depend({
	bs_v612.switch,
	true
})
	bs_v612.show_label = bs_v614:switch("Show Label", true):depend({
	bs_v612.switch,
	true
})
	bs_v612.show_ticks = bs_v614:switch("Show Ticks", true):depend({
	bs_v612.switch,
	true
})
	bs_v612.show_bar = bs_v614:switch("Show Bar", true):depend({
	bs_v612.switch,
	true
})
bs_v590.lc_indicator = bs_v612
bs_v623 = {
	 switch = bs_v582:switch("\v\f<gauge-high>\r  Velocity Indicator"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v628 = bs_v623.switch:create()
bs_v623.col_bar = bs_v628:color_picker("bar high", color(150, 195, 255, 255)):depend({
	bs_v623.switch,
	true
})
bs_v623.col_bar2 = bs_v628:color_picker("bar normal", color(255, 255, 255, 255)):depend({
	bs_v623.switch,
	true
})
	bs_v623.glow = bs_v628:switch("Glow", true):depend({
	bs_v623.switch,
	true
})
bs_v623.col_text = bs_v628:color_picker("text color", color(185, 185, 190, 255)):depend({
	bs_v623.switch,
	true
})
	bs_v623.show_label = bs_v628:switch("Show Label", true):depend({
	bs_v623.switch,
	true
})
	bs_v623.show_percent = bs_v628:switch("Show Percent", true):depend({
	bs_v623.switch,
	true
})
bs_v590.velocity_indicator = bs_v623
bs_v627 = {
	 switch = bs_v582:switch("\v\f<shield-halved>\r  Bruteforce Indicator"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v645 = bs_v627.switch:create()
bs_v627.col_bar = bs_v645:color_picker("bar color normal", color(150, 195, 255, 255)):depend({
	bs_v627.switch,
	true
})
bs_v627.col_bar2 = bs_v645:color_picker("bar color missed", color(255, 64, 64, 255)):depend({
	bs_v627.switch,
	true
})
	bs_v627.glow = bs_v645:switch("Glow", true):depend({
	bs_v627.switch,
	true
})
bs_v627.col_idle = bs_v645:color_picker("bar idle", color(80, 80, 90, 255)):depend({
	bs_v627.switch,
	true
})
	bs_v627.show_label = bs_v645:switch("Show Label", true):depend({
	bs_v627.switch,
	true
})
	bs_v627.show_timer = bs_v645:switch("Show Timer", true):depend({
	bs_v627.switch,
	true
})
bs_v590.abf_indicator = bs_v627
bs_v644 = {
	 switch = bs_v582:switch("\v\f<shield>\r  Defensive Indicator"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v644.color = bs_v644.switch:create():color_picker(bs_fmt("color"), color(150, 195, 255, 255)):depend({
	bs_v644.switch,
	true
})
bs_v590.def_indicator = bs_v644
bs_v654 = {
	 label = bs_v576:label("\v\f<marker>\r  Watermark"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v662 = bs_v654.label:create()
bs_v654.style = bs_v662:combo(bs_fmt("style"), {
	"classic",
	"modern",
	"logo"
}, "classic")
bs_v654.col1 = bs_v662:color_picker("color 1", color(160, 160, 185, 255)):depend({
	bs_v654.style,
	"classic"
})
bs_v654.col2 = bs_v662:color_picker("color 2", color(255, 255, 255, 255)):depend({
	bs_v654.style,
	"classic"
})
bs_v654.col3 = bs_v662:color_picker("color 3", color(150, 195, 255, 255)):depend({
	bs_v654.style,
	"classic"
})
bs_v654.col_wave = bs_v662:color_picker("wave color", color(255, 255, 255, 255)):depend({
	bs_v654.style,
	"classic"
})
	bs_v654.position = bs_v662:combo("Position", {
	"bottom center",
	"left center"
}, "bottom center"):depend({
	bs_v654.style,
	"classic"
})
	bs_v654.font = bs_v662:combo("Font", {
	"classic",
	"pixel"
}, "classic"):depend({
	bs_v654.style,
	"classic"
})
	bs_v654.name_case = bs_v662:combo("Name Case", {
	"uppercase",
	"lowercase"
}, "uppercase"):depend({
	bs_v654.style,
	"classic"
}, {
	bs_v654.font,
	"classic"
})
bs_v654.m_col_bg = bs_v662:color_picker("background", color(15, 15, 18, 210)):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_col_border = bs_v662:color_picker("border", color(255, 255, 255, 40)):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_col_text = bs_v662:color_picker("text color", color(133, 133, 133, 191)):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_col_accent = bs_v662:color_picker("accent", color(133, 133, 133, 191)):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_col_shimmer = bs_v662:color_picker("shimmer color", color(210, 210, 225, 255)):depend({
	bs_v654.style,
	"modern"
})
	bs_v654.m_logo_mode = bs_v662:combo("Logo Mode", {
	"logo",
	"text"
}, "logo"):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_text_case = bs_v662:combo(bs_fmt("text case"), {
	"lowercase",
	"uppercase"
}, "lowercase"):depend({
	bs_v654.style,
	"modern"
}, {
	bs_v654.m_logo_mode,
	"text"
})
bs_v654.m_font = bs_v662:combo(bs_fmt("font"), {
	"inter",
	"verdana"
}, "inter"):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_show_nick = bs_v662:switch(bs_fmt("show nickname"), true):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_show_fps = bs_v662:switch(bs_fmt("show fps"), true):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_show_ping = bs_v662:switch(bs_fmt("show ping"), false):depend({
	bs_v654.style,
	"modern"
})
bs_v654.m_shimmer_en = bs_v662:switch(bs_fmt("shimmer"), true):depend({
	bs_v654.style,
	"modern"
})
bs_v654.w_col = bs_v662:color_picker("logo color", color(255, 255, 255, 255)):depend({
	bs_v654.style,
	"logo"
})
bs_v590.watermark = bs_v654
bs_v661 = {
	 label = bs_v576:label("\v\f<crosshairs>\r  Crosshair Indicators"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v670 = bs_v661.label:create()
bs_v661.enabled = bs_v670:switch(bs_fmt("enabled"))
	bs_v661.style = bs_v670:combo("Style", {
	"modern",
	"old"
}, "modern"):depend({
	bs_v661.enabled,
	true
})
	bs_v661.font = bs_v670:combo("Font", {
	"normal",
	"pixel",
	"bold"
}, "bold"):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"modern"
})
	bs_v661.glow = bs_v670:switch("Glow", false):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"modern"
})
bs_v661.glow_color = bs_v670:color_picker("glow color", color(255, 255, 255, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.glow,
	true
}, {
	bs_v661.style,
	"modern"
})
bs_v661.m_col_accent = bs_v670:color_picker("accent", color(200, 200, 210, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"modern"
})
bs_v661.col_wave = bs_v670:color_picker("wave color", color(255, 255, 255, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"modern"
})
	bs_v661.m_show_state = bs_v670:switch("Show State", true):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"modern"
})
	bs_v661.m_show_dt = bs_v670:switch("Show DT", true):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"modern"
})
	bs_v661.m_show_hs = bs_v670:switch("Show Hide Shots", true):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"modern"
})
	bs_v661.m_show_fs = bs_v670:switch("Show Freestanding", true):depend({
		bs_v661.enabled,
		true
	}, {
		bs_v661.style,
		"modern"
	})
	bs_v661.m_show_hc = bs_v670:switch("Show HC", true):depend({
		bs_v661.enabled,
		true
	}, {
		bs_v661.style,
		"modern"
	})
	bs_v661.hc_col = bs_v670:color_picker("hc color", color(200, 200, 210, 255)):depend({
		bs_v661.enabled,
		true
	}, {
		bs_v661.style,
		"modern"
	}, {
		bs_v661.m_show_hc,
		true
	})
	bs_v661.new_show_state = bs_v670:switch("Show State", true):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
})
bs_v661.new_title_col = bs_v670:color_picker("title color", color(185, 190, 255, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
})
bs_v661.new_grad_col = bs_v670:color_picker("gradient color", color(130, 170, 255, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
})
bs_v661.new_shot_col = bs_v670:color_picker("shot color", color(255, 255, 255, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
})
bs_v661.new_state_col = bs_v670:color_picker("state color", color(200, 200, 200, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
})
bs_v661.new_flags_col = bs_v670:color_picker("flags color", color(255, 255, 255, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
})
bs_v661.new_show_hc = bs_v670:switch("Show HC", true):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
})
bs_v661.new_hc_col = bs_v670:color_picker("hc color", color(200, 200, 210, 255)):depend({
	bs_v661.enabled,
	true
}, {
	bs_v661.style,
	"old"
}, {
	bs_v661.new_show_hc,
	true
})
bs_v590.crosshair = bs_v661
bs_v676 = {
	 label = bs_v576:label("\v\f<bell>\r  Notifications"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v679 = bs_v676.label:create()
bs_v676.log_mode = bs_v679:combo(bs_fmt("mode"), {
	"widget",
	"text"
}, "widget")
	bs_v676.prefix_mode = bs_v679:combo("Prefix", {
	"text",
	"icon"
}, "text"):depend({
	bs_v676.log_mode,
	"widget"
})
	bs_v676.blur = bs_v679:switch("Background Blur", true):depend({
	bs_v676.log_mode,
	"widget"
})
	bs_v676.glow = bs_v679:switch("Background Glow", false):depend({
	bs_v676.log_mode,
	"widget"
})
	bs_v676.font = bs_v679:combo("Font", {
	"inter",
	"verdana"
}, "inter"):depend({
	bs_v676.log_mode,
	"widget"
})
	bs_v676.anim_style = bs_v679:combo("Style", {
	"classic",
	"new"
}, "classic"):depend({
	bs_v676.log_mode,
	"widget"
})
bs_v676.col_glass = bs_v679:color_picker("glass tint", color(255, 255, 255, 18)):depend({
	bs_v676.log_mode,
	"widget"
})
bs_v676.col_border = bs_v679:color_picker("border", color(255, 255, 255, 45)):depend({
	bs_v676.log_mode,
	"widget"
})
bs_v676.col_accent = bs_v679:color_picker("accent", color(150, 195, 255, 255)):depend({
	bs_v676.log_mode,
	"widget"
})
bs_v676.col_text = bs_v679:color_picker("text", color(220, 220, 225, 255)):depend({
	bs_v676.log_mode,
	"widget"
})
	bs_v676.log_enabled = bs_v679:switch("Enabled Log", false)
	bs_v676.log_hits = bs_v679:switch("Show Hits", true):depend({
	bs_v676.log_enabled,
	true
})
	bs_v676.log_misses = bs_v679:switch("Show Misses", true):depend({
	bs_v676.log_enabled,
	true
})
	bs_v676.log_hurt = bs_v679:switch("Show Hurt", true):depend({
	bs_v676.log_enabled,
	true
})
	bs_v676.log_purchases = bs_v679:switch("Show Purchases", true):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_mode,
	"text"
})
bs_v676.col_purchases = bs_v679:color_picker("purchase color", color(150, 195, 255, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_mode,
	"text"
}, {
	bs_v676.log_purchases,
	true
})
bs_v676.col_hit = bs_v679:color_picker("hit color", color(125, 210, 125, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_hits,
	true
})
bs_v676.col_miss = bs_v679:color_picker("miss color", color(220, 80, 80, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_misses,
	true
})
bs_v676.col_mismatch = bs_v679:color_picker("mismatch color", color(255, 159, 94, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_mode,
	"text"
}, {
	bs_v676.log_hits,
	true
})
bs_v676.col_miss_mismatch = bs_v679:color_picker("miss mismatch color", color(255, 159, 94, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_mode,
	"text"
}, {
	bs_v676.log_misses,
	true
})
	bs_v676.log_dormant = bs_v679:switch("Show Dormant", true):depend({
	bs_v676.log_enabled,
	true
})
bs_v676.col_dormant_hit = bs_v679:color_picker("dormant hit color", color(106, 255, 84, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_dormant,
	true
})
bs_v676.col_dormant_miss = bs_v679:color_picker("dormant miss color", color(255, 115, 115, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_dormant,
	true
})
bs_v676.col_hurt = bs_v679:color_picker("hurt color", color(163, 166, 255, 255)):depend({
	bs_v676.log_enabled,
	true
}, {
	bs_v676.log_hurt,
	true
})
	bs_v676.log_console = bs_v679:switch("Print To Console", true):depend({
	bs_v676.log_enabled,
	true
})
bs_v676.col_abf_hit = bs_v679:color_picker("abf hit color", color(0, 255, 0, 255)):depend({
	bs_v676.log_mode,
	"widget"
})
bs_v676.col_abf_miss = bs_v679:color_picker("abf miss color", color(255, 0, 0, 255)):depend({
	bs_v676.log_mode,
	"widget"
})
bs_v676.col_abf_hit_text = bs_v679:color_picker("abf hit color text", color(0, 255, 0, 255)):depend({
	bs_v676.log_mode,
	"text"
})
bs_v676.col_abf_miss_text = bs_v679:color_picker("abf miss color text", color(255, 0, 0, 255)):depend({
	bs_v676.log_mode,
	"text"
})
bs_v590.notify = bs_v676
bs_v684 = {
	 label = bs_v576:label("\v\f<wand-magic-sparkles>\r  Visual Tweaks"):depend({
		bs_v564,
		bs_v549
	})
}
bs_v687 = bs_v684.label:create()
	bs_v684.remove_shadow = bs_v687:switch("Remove Shadow", false)
	bs_v684.remove_weapon = bs_v687:switch("Remove Weapon On Thirdperson", false)
	bs_v684.console_mod = bs_v687:switch("Console Modulation", false)
	bs_v684.console_mod_col = bs_v687:color_picker("color", color(47, 47, 60, 222)):depend({
		bs_v684.console_mod,
		true
	})
bs_v590.additions = bs_v684
bs_v693 = {
	 label = bs_v576:label("\v\f<magnifying-glass>\r  Scope Zoom"):depend({
		bs_v564,
		bs_v549
	})
}
bs_v696 = bs_v693.label:create()
	bs_v693.enabled = bs_v696:switch("Animate Zoom")
	bs_v693.speed = bs_v696:slider("Animation Speed", 1, 100, 50, 1, "%"):depend({
	bs_v693.enabled,
	true
})
bs_v590.scope_zoom = bs_v693
bs_v704 = {
	 label = bs_v582:label("\v\f<bullseye>\r  Hitmarker"):depend({
		bs_v564,
		bs_v555
	})
}
bs_v707 = bs_v704.label:create()
	bs_v704.enabled = bs_v707:switch("Hitmarker")
	bs_v704.duration = bs_v707:slider("Duration", 0, 10, 1, 1, "s"):depend({
	bs_v704.enabled,
	true
})
	bs_v704.size = bs_v707:slider("Size", 8, 32, 18, 1, "px"):depend({
	bs_v704.enabled,
	true
})
bs_v704.col_hit = bs_v707:color_picker("color", color(255, 255, 255, 230)):depend({
	bs_v704.enabled,
	true
})
bs_v704.col_miss = bs_v707:color_picker("color miss", color(220, 80, 80, 200)):depend({
	bs_v704.enabled,
	true
})
bs_v704.col_kill = bs_v707:color_picker("color kill", color(255, 180, 0, 255)):depend({
	bs_v704.enabled,
	true
})
	bs_v704.explode_effect = bs_v707:switch("Explode Effect"):depend({
	bs_v704.enabled,
	true
})
	bs_v704.dm_enabled = bs_v707:switch("Damage Numbers")
bs_v704.dm_col_hit = bs_v707:color_picker("dmg color", color(255, 255, 255, 230)):depend({
	bs_v704.dm_enabled,
	true
})
bs_v704.dm_col_kill = bs_v707:color_picker("dmg kill color", color(255, 180, 0, 255)):depend({
	bs_v704.dm_enabled,
	true
})
bs_v590.hitmarker = bs_v704
bs_v714 = {
	 label = bs_v582:label("\v\f<camera>\r  Viewmodel"):depend({
		bs_v564,
		bs_v549
	})
}
bs_v717 = bs_v714.label:create()
bs_v714.enabled = bs_v717:switch(bs_fmt("enabled"))
bs_v714.fov = bs_v717:slider(bs_fmt("fov"), 40, 120, 68, 1, function(arg_67_0)
	return "FOV: " .. arg_67_0
end):depend({
	bs_v714.enabled,
	true
})
bs_v714.x = bs_v717:slider(bs_fmt("x"), -100, 100, 0, 1, function(arg_68_0)
	return "x: " .. arg_68_0 * 0.1
end):depend({
	bs_v714.enabled,
	true
})
bs_v714.y = bs_v717:slider(bs_fmt("y"), -100, 100, 0, 1, function(arg_69_0)
	return "y: " .. arg_69_0 * 0.1
end):depend({
	bs_v714.enabled,
	true
})
bs_v714.z = bs_v717:slider(bs_fmt("z"), -100, 100, 0, 1, function(arg_70_0)
	return "z: " .. arg_70_0 * 0.1
end):depend({
	bs_v714.enabled,
	true
})
bs_v714.viewmodel_in_scope = bs_v717:switch(bs_fmt("viewmodel in scope"), false):depend({
	bs_v714.enabled,
	true
})
bs_v714.scope_anim_speed = bs_v717:slider(bs_fmt("animation speed"), 1, 200, 90, 1, function(arg_71_0)
	return "speed: " .. string.format("%.1f", arg_71_0 * 0.1)
end):depend({
	bs_v714.viewmodel_in_scope,
	true
}):depend({
	bs_v714.enabled,
	true
})
bs_v714.scope_x = bs_v717:slider(bs_fmt("scope x"), -100, 100, 0, 1, function(arg_72_0)
	return "x: " .. string.format("%.1f", arg_72_0 * 0.1)
end):depend({
	bs_v714.viewmodel_in_scope,
	true
}):depend({
	bs_v714.enabled,
	true
})
bs_v714.scope_y = bs_v717:slider(bs_fmt("scope y"), -100, 100, 0, 1, function(arg_73_0)
	return "y: " .. string.format("%.1f", arg_73_0 * 0.1)
end):depend({
	bs_v714.viewmodel_in_scope,
	true
}):depend({
	bs_v714.enabled,
	true
})
bs_v714.scope_z = bs_v717:slider(bs_fmt("scope z"), -100, 100, 0, 1, function(arg_74_0)
	return "z: " .. string.format("%.1f", arg_74_0 * 0.1)
end):depend({
	bs_v714.viewmodel_in_scope,
	true
}):depend({
	bs_v714.enabled,
	true
})
bs_v714.reset = bs_v717:button(bs_fmt("reset"), function()
	bs_v714.fov:set(68)
	bs_v714.x:set(0)
	bs_v714.y:set(0)
	bs_v714.z:set(0)
	bs_v714.scope_anim_speed:set(90)
	bs_v714.scope_x:set(0)
	bs_v714.scope_y:set(0)
	bs_v714.scope_z:set(0)
end, true):depend({
	bs_v714.enabled,
	true
})
bs_v590.viewmodel = bs_v714
bs_v725 = {
	 label = bs_v582:label("\v\f<crosshairs>\r  Custom Scope"):depend({
		bs_v564,
		bs_v549
	})
}
bs_v729 = bs_v725.label:create()
bs_v725.enabled = bs_v729:switch(bs_fmt("enabled"))
bs_v725.disable_animation = bs_v729:switch(bs_fmt("disable animation"), false):depend({
	bs_v725.enabled,
	true
})
bs_v725.anim_speed = bs_v729:slider(bs_fmt("animation speed"), 1, 20, 5):depend({
	bs_v725.enabled,
	true
}):depend({
	bs_v725.disable_animation,
	false
})
bs_v725.glow = bs_v729:switch(bs_fmt("glow"), false):depend({
	bs_v725.enabled,
	true
})
bs_v725.glow_color = bs_v729:color_picker(bs_fmt("glow color"), color(255, 255, 255, 180)):depend({
	bs_v725.enabled,
	true
}):depend({
	bs_v725.glow,
	true
})
bs_v725.length = bs_v729:slider(bs_fmt("length"), 10, 300, 185):depend({
	bs_v725.enabled,
	true
})
bs_v725.gap = bs_v729:slider(bs_fmt("gap"), 1, 300, 5):depend({
	bs_v725.enabled,
	true
})
bs_v725.color_main = bs_v729:color_picker(bs_fmt("main color"), color(255, 255, 255, 255)):depend({
	bs_v725.enabled,
	true
})
bs_v725.color_edge = bs_v729:color_picker(bs_fmt("edge color"), color(0, 0, 0, 255)):depend({
	bs_v725.enabled,
	true
})
bs_v590.custom_scope = bs_v725
bs_v728 = {
	 switch = bs_v582:switch("\v\f<eye-slash>\r  Custom Silentaim"):depend({
		bs_v564,
		bs_v549
	})
}
bs_v740 = bs_v728.switch:create()
	bs_v728.fov = bs_v740:slider("FOV", 1, 180, 5, 1, "°"):depend({
	bs_v728.switch,
	true
})
bs_v590.silent_view = bs_v728
bs_v590.sidebar = {}
bs_menu.visuals = bs_v590
bs_menu.info.notify = bs_v676
bs_hud_theme = bs_v676
bs_menu.info.crosshair = bs_v661
bs_menu.info.watermark = bs_v654
bs_menu.info.lc_ind = bs_v612
bs_menu.info.velocity = bs_v623
bs_menu.info.abf_ind = bs_v627
bs_menu.info.def_ind = bs_v644
bs_menu.info.additions = bs_v684
bs_menu.info.scope_zoom = bs_v693
bs_menu.info.hitmarker = bs_v590.hitmarker
bs_menu.info.viewmodel = bs_v714
bs_menu.info.custom_scope = bs_v725
;({}).get = function()
	return true
end
	bs_indicators_switch = bs_v576:switch("\v\f<chart-line>\r  Side Indicators", false):depend({
	bs_v564,
	bs_v555
})
bs_indicators_cfg = bs_indicators_switch:create()
bs_v622 = bs_indicators_cfg:color_picker("background color", color(0, 0, 0, 200))
bs_v626 = bs_indicators_cfg:selectable("active side indicators", {
	"double tap",
	"hide shots",
	"freestanding",
	"fake duck",
	"min damage",
	"dormant aimbot",
	"lc",
	"ping",
	"tickbase",
	"hc"
})
	bs_rage_indicators = bs_v626
bs_ui_elements.col_dt_on = bs_indicators_cfg:color_picker("dt  charged", color(175, 175, 180, 255)):depend({
	bs_v626,
	"double tap"
})
bs_ui_elements.col_dt_off = bs_indicators_cfg:color_picker("dt  not charged", color(200, 80, 80, 255)):depend({
	bs_v626,
	"double tap"
})
bs_ui_elements.col_hs_on = bs_indicators_cfg:color_picker("hs  color", color(175, 175, 180, 255)):depend({
	bs_v626,
	"hide shots"
})
bs_ui_elements.col_fs_on = bs_indicators_cfg:color_picker("fs  color", color(175, 175, 180, 255)):depend({
	bs_v626,
	"freestanding"
})
bs_ui_elements.col_fd_on = bs_indicators_cfg:color_picker("fd  color", color(175, 175, 180, 255)):depend({
	bs_v626,
	"fake duck"
})
bs_ui_elements.col_da_on = bs_indicators_cfg:color_picker("da  color", color(175, 175, 180, 255)):depend({
	bs_v626,
	"dormant aimbot"
})
bs_ui_elements.col_dmg_on = bs_indicators_cfg:color_picker("dmg color", color(175, 175, 180, 255)):depend({
	bs_v626,
	"min damage"
})
bs_ui_elements.col_lc_on = bs_indicators_cfg:color_picker("lc  active", color(175, 175, 180, 255)):depend({
	bs_v626,
	"lc"
})
bs_ui_elements.col_lc_bad = bs_indicators_cfg:color_picker("lc  bad/failed", color(200, 80, 80, 255)):depend({
	bs_v626,
	"lc"
})
bs_ui_elements.col_ping_on = bs_indicators_cfg:color_picker("ping color", color(175, 175, 180, 255)):depend({
	bs_v626,
	"ping"
})
bs_ui_elements.col_off = {
	get = function()
		return color(75, 75, 80, 255)
	end
}
bs_ui_elements.col_text = {
	get = function()
		return color(175, 175, 180, 255)
	end
}
bs_ui_elements.enabled = {
	get = function()
		return bs_indicators_switch:get()
	end
}
bs_ui_elements.show_dt = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("double tap")
		end
	}
	bs_ui_elements.show_hs = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("hide shots")
		end
	}
	bs_ui_elements.show_fs = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("freestanding")
		end
	}
	bs_ui_elements.show_fd = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("fake duck")
		end
	}
	bs_ui_elements.show_dmg = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("min damage")
		end
	}
	bs_ui_elements.show_da = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("dormant aimbot")
		end
	}
	bs_ui_elements.show_lc = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("lc")
		end
	}
	bs_ui_elements.show_ping = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("ping")
		end
	}
	bs_ui_elements.show_tickbase = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("tickbase")
		end
	}
	bs_ui_elements._hc_ind = {
		get = function()
			return bs_rage_indicators and bs_rage_indicators:get("hc")
		end
	}
bs_ui_elements.col_bg = bs_v622
bs_ui_elements.col_border = {
	get = function()
		return color(0, 0, 0, 0)
	end
}
	bs_ui_elements.blur = bs_indicators_cfg:switch("Background Blur", false)
	bs_ui_elements.font = bs_indicators_cfg:combo("Font", {
	"inter",
	"verdana"
}, "inter")
bs_ui_elements._select = bs_v626
bs_ui_elements._label = bs_indicators_switch
bs_menu.info.side_ind = bs_indicators_switch
	bs_v643 = bs_v576:switch("\v\f<keyboard>\r  Keybinds", false):depend({
	bs_v564,
	bs_v555
})
bs_v653 = bs_v643:create()
bs_v668 = {
	enabled = bs_v643,
	show_bg = bs_v653:switch("Show Keybind Background", true),
	col_bg = bs_v653:color_picker("background", color(15, 15, 18, 210)),
	col_border = bs_v653:color_picker("border", color(255, 255, 255, 40)),
	col_text = bs_v653:color_picker("text color", color(133, 133, 133, 191)),
	col_accent = bs_v653:color_picker("accent", color(133, 133, 133, 191)),
	font = bs_v653:combo("Font", {
		"inter",
		"verdana"
	}, "inter")
}
bs_menu.info.keybinds = bs_v643
bs_menu.info.keybinds_ui = bs_v668
bs_v601 = bs_pui.create(bs_menu_icons.misc, "       ", 1)
bs_v611 = bs_pui.create(bs_menu_icons.misc, "         ", 2)
bs_v621 = {}

-- #############################################################################
-- #  [SEC-04] MENU TABS (MISC / EXPLOITS / AIMBOT / MOVEMENT / EXTRAS)
-- #############################################################################
-- ========== MISC TABS ==========
bs_v626 = bs_pui.create(bs_menu_icons.misc, "\v\f<hammer>\r  Categories", 2)
bs_v644 = {
	"\f<crosshairs>\r  Aimbot",
	"\f<plane-up>\r  Movement & Animation",
	"\f<star>\r  Extras"
}
bs_v654 = 1
bs_v663 = 2
bs_v671 = 3
bs_v680 = 4
bs_v698 = bs_v626:list("", bs_v644)

-- ========== AIMBOT TAB ==========
bs_fake_lag_editor = {
	-- Global Fake Lag editor
	fake_lag_editor = bs_v601:switch("\v\f<rotate>\r  FakeLag Editor"):depend({ bs_v698, bs_v654 }),
	fake_lag_editor_gear = nil,
	fake_lag_editor_mode = nil,
}

-- FakeLag Editor gear
bs_fake_lag_editor.fake_lag_editor_gear = bs_fake_lag_editor.fake_lag_editor:create()
bs_fake_lag_editor.fake_lag_editor_mode = bs_fake_lag_editor.fake_lag_editor_gear:combo("Mode", { "Default", "Dynamic", "Maximum", "Jitter", "Flicker" }):depend({ bs_fake_lag_editor.fake_lag_editor, true })
bs_fake_lag_editor.fake_lag_default_limit = bs_fake_lag_editor.fake_lag_editor_gear:slider("Default Limit", 1, 15, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Default" })
bs_fake_lag_editor.fake_lag_default_variability = bs_fake_lag_editor.fake_lag_editor_gear:slider("Default Variability", 0, 100, 0, 1, "%"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Default" })
bs_fake_lag_editor.fake_lag_dynamic_limit = bs_fake_lag_editor.fake_lag_editor_gear:slider("Dynamic Limit", 1, 15, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Dynamic" })
bs_fake_lag_editor.fake_lag_dynamic_variability = bs_fake_lag_editor.fake_lag_editor_gear:slider("Dynamic Variability", 0, 100, 0, 1, "%"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Dynamic" })
bs_fake_lag_editor.fake_lag_maximum_variability = bs_fake_lag_editor.fake_lag_editor_gear:slider("Maximum Variability", 0, 100, 0, 1, "%"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Maximum" })
bs_fake_lag_editor.fake_lag_jitter_limit = bs_fake_lag_editor.fake_lag_editor_gear:slider("Jitter Limit", 1, 15, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Jitter" })
bs_fake_lag_editor.fake_lag_jitter_override = bs_fake_lag_editor.fake_lag_editor_gear:slider("Jitter Limit Override", 1, 15, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Jitter" })
bs_fake_lag_editor.fake_lag_jitter_timer = bs_fake_lag_editor.fake_lag_editor_gear:slider("Jitter Switch Timer", 1, 50, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Jitter" })
bs_fake_lag_editor.fake_lag_jitter_variability = bs_fake_lag_editor.fake_lag_editor_gear:slider("Jitter Variability", 0, 100, 0, 1, "%"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Jitter" })
bs_fake_lag_editor.fake_lag_flicker_limit = bs_fake_lag_editor.fake_lag_editor_gear:slider("Flicker Limit", 1, 15, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Flicker" })
bs_fake_lag_editor.fake_lag_flicker_override = bs_fake_lag_editor.fake_lag_editor_gear:slider("Flicker Limit Override", 1, 15, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Flicker" })
bs_fake_lag_editor.fake_lag_flicker_timer = bs_fake_lag_editor.fake_lag_editor_gear:slider("Flicker Switch Timer", 1, 50, 1, 1, "t"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Flicker" })
bs_fake_lag_editor.fake_lag_flicker_variability = bs_fake_lag_editor.fake_lag_editor_gear:slider("Flicker Variability", 0, 100, 0, 1, "%"):depend({ bs_fake_lag_editor.fake_lag_editor, true }, { bs_fake_lag_editor.fake_lag_editor_mode, "Flicker" })

bs_v621.exploits = bs_fake_lag_editor

-- ========== EXPLOITS RUNTIME ==========
-- FakeLag Editor runtime
do
	local fe = bs_fake_lag_editor
	local fake_lag_editor_active = false

	local function fake_lag_mode_name()
		local mode = fe.fake_lag_editor_mode
		if not mode then return "default" end
		return tostring(mode:get()):lower()
	end

	local function fake_lag_settings()
		local mode = fake_lag_mode_name()
		local fe = bs_fake_lag_editor

		if mode == "dynamic" then
			return mode, fe.fake_lag_dynamic_limit:get(), nil, nil, fe.fake_lag_dynamic_variability:get()
		elseif mode == "maximum" then
			return mode, nil, nil, nil, fe.fake_lag_maximum_variability:get()
		elseif mode == "jitter" then
			return mode, fe.fake_lag_jitter_limit:get(), fe.fake_lag_jitter_override:get(), fe.fake_lag_jitter_timer:get(), fe.fake_lag_jitter_variability:get()
		elseif mode == "flicker" then
			return mode, fe.fake_lag_flicker_limit:get(), fe.fake_lag_flicker_override:get(), fe.fake_lag_flicker_timer:get(), fe.fake_lag_flicker_variability:get()
		end

		return "default", fe.fake_lag_default_limit:get(), nil, nil, fe.fake_lag_default_variability:get()
	end

	local function release_fake_lag_editor()
		pcall(function()
			bs_config.antiaim.fake_lag.enabled:override()
		end)
		pcall(function()
			bs_config.antiaim.fake_lag.limit:override()
		end)
		pcall(function()
			bs_config.antiaim.fake_lag.variability:override()
		end)
		pcall(function()
			bs_config.antiaim.fake_lag.enabled_pui:override()
		end)
		pcall(function()
			bs_config.antiaim.fake_lag.limit_pui:override()
		end)
	end

	local function fake_lag_value()
		local mode, base_limit, override_limit, switch_timer = fake_lag_settings()
		local timer = math.max(1, switch_timer or 1)

		if mode == "dynamic" then
			local player = entity.get_local_player()
			local in_air = true

			if player then
				in_air = bit.band(player.m_fFlags or 0, 1) ~= 1
			end

			if in_air then
				return math.max(math.random(12, 15), base_limit)
			end

			return math.min(math.random(5, 6), base_limit)
		elseif mode == "maximum" then
			local max_process_ticks = 14

			pcall(function()
				max_process_ticks = cvar.sv_maxusrcmdprocessticks:int()
			end)

			return math.max(14, max_process_ticks)
		elseif mode == "jitter" then
			return math.floor(globals.tickcount / timer) % 2 == 0 and base_limit or override_limit
		elseif mode == "flicker" then
			return globals.tickcount % timer == 0 and base_limit or override_limit
		end

		return base_limit
	end

	events.createmove(function()
		if not bs_fake_lag_editor.fake_lag_editor:get() then
			if fake_lag_editor_active then
				release_fake_lag_editor()
				fake_lag_editor_active = false
			end

			return
		end

		fake_lag_editor_active = true

		local fl_value = fake_lag_value()

		pcall(function()
			bs_config.antiaim.fake_lag.enabled:override(true)
		end)
		pcall(function()
			bs_config.antiaim.fake_lag.limit:override(fl_value)
		end)
		pcall(function()
			local _, _, _, _, variability = fake_lag_settings()

			bs_config.antiaim.fake_lag.variability:override(variability)
		end)
		pcall(function()
			bs_config.antiaim.fake_lag.enabled_pui:override(true)
		end)
		pcall(function()
			bs_config.antiaim.fake_lag.limit_pui:override(fl_value)
		end)
	end)

	local function clear_fake_lag_editor()
		if fake_lag_editor_active then
			release_fake_lag_editor()
			fake_lag_editor_active = false
		end
	end

	events.round_start(clear_fake_lag_editor)
	events.level_change(clear_fake_lag_editor)
	events.player_death(function(event)
		local player = entity.get_local_player()

		if player and entity.get(event.userid, true) == player then
			clear_fake_lag_editor()
		end
	end)

	local function update_fake_lag_menu()
		local editor_enabled = bs_fake_lag_editor.fake_lag_editor:get()
		local mode = fake_lag_mode_name()
		local fe = bs_fake_lag_editor

		fe.fake_lag_editor_mode:visibility(editor_enabled)
		fe.fake_lag_default_limit:visibility(editor_enabled and mode == "default")
		fe.fake_lag_default_variability:visibility(editor_enabled and mode == "default")
		fe.fake_lag_dynamic_limit:visibility(editor_enabled and mode == "dynamic")
		fe.fake_lag_dynamic_variability:visibility(editor_enabled and mode == "dynamic")
		fe.fake_lag_maximum_variability:visibility(editor_enabled and mode == "maximum")
		fe.fake_lag_jitter_limit:visibility(editor_enabled and mode == "jitter")
		fe.fake_lag_jitter_override:visibility(editor_enabled and mode == "jitter")
		fe.fake_lag_jitter_timer:visibility(editor_enabled and mode == "jitter")
		fe.fake_lag_jitter_variability:visibility(editor_enabled and mode == "jitter")
		fe.fake_lag_flicker_limit:visibility(editor_enabled and mode == "flicker")
		fe.fake_lag_flicker_override:visibility(editor_enabled and mode == "flicker")
		fe.fake_lag_flicker_timer:visibility(editor_enabled and mode == "flicker")
		fe.fake_lag_flicker_variability:visibility(editor_enabled and mode == "flicker")
	end

	bs_fake_lag_editor.fake_lag_editor:set_callback(update_fake_lag_menu, true)
	bs_fake_lag_editor.fake_lag_editor_mode:set_callback(update_fake_lag_menu, true)
events.render(function()
		update_fake_lag_menu()
	end)
end

-- ========== AIMBOT TAB ==========
bs_v718 = {
	unlock_latency = bs_v601:switch("\v\f<gauge-high>\r  Unlock Fake Latency", false):depend({ bs_v698, bs_v654 }),
	-- DT Modifier
	dt_modifier = bs_v601:switch("\v\f<bolt>\r  DT Speed Modifier"):depend({ bs_v698, bs_v654 }),
	dt_modifier_gear = nil,
	dt_modifier_mode = nil,
	dt_modifier_custom = nil,
	-- Force Shoot
	force_shoot = bs_v601:switch("\v\f<bolt>\r  Force Shoot"):depend({ bs_v698, bs_v654 }),
	force_shoot_gear = nil,
	force_shoot_mode = nil,
	force_shoot_condition = nil,
	force_shoot_hitbox = nil,
	force_shoot_hitbox_delay = nil,
}
bs_v718.unlock_latency:set_callback(function(arg_89_0)
	cvar.sv_maxunlag:float(arg_89_0:get() and 2 or 0.1)
end)

-- DT Modifier gear
bs_v718.dt_modifier_gear = bs_v718.dt_modifier:create()
bs_v718.dt_modifier_mode = bs_v718.dt_modifier_gear:combo("Mode", { "Instant", "Normal", "Custom" }):depend({ bs_v718.dt_modifier, true })
local max_process_ticks = cvar.sv_maxusrcmdprocessticks:int()
	bs_v718.dt_modifier_gear:label("\v\f<info>\r  Server max process ticks: " .. max_process_ticks):depend({ bs_v718.dt_modifier, true })
	bs_v718.dt_modifier_custom = bs_v718.dt_modifier_gear:slider("Custom Ticks", 0, 24, 14, 1):depend({ bs_v718.dt_modifier, true }, { bs_v718.dt_modifier_mode, "Custom" })
	bs_v718.dt_modifier_gear:label("\v\f<check>\r  Safe: 15 (Instant), 14 (Normal) | Max allowed: 24"):depend({ bs_v718.dt_modifier, true })

-- Force Shoot gear
bs_v718.force_shoot_gear = bs_v718.force_shoot:create()
bs_v718.force_shoot_mode = bs_v718.force_shoot_gear:combo("Mode", {
	"On Enemy Shot",
	"On Peek (Visible)",
	"On DT Charged",
	"Always"
}):depend({ bs_v718.force_shoot, true })
bs_v718.force_shoot_condition = bs_v718.force_shoot_gear:selectable("Conditions", {
	"Enemy Visible",
	"Enemy Not Dormant",
	"DT Ready",
	"HS Ready",
	"In Air"
}, 0):depend({ bs_v718.force_shoot, true })

-- Hitbox override (shows when mode = On Enemy Shot)
bs_v718.force_shoot_hitbox = bs_v718.force_shoot_gear:combo("Hitbox Override", { 
	"Off", 
	"Head Only", 
	"Head + Neck", 
	"Head Priority" 
}):depend({ bs_v718.force_shoot, true }, { bs_v718.force_shoot_mode, "On Enemy Shot" })
bs_v718.force_shoot_hitbox_delay = bs_v718.force_shoot_gear:slider("Hitbox Delay (ticks)", 0, 10, 1, 1):depend({ bs_v718.force_shoot, true }, { bs_v718.force_shoot_mode, "On Enemy Shot" }, { bs_v718.force_shoot_hitbox, "Head Only", "Head + Neck", "Head Priority" })
bs_v718.force_shoot_gear:label("\v\f<info>\r  Forces shot when condition met"):depend({ bs_v718.force_shoot, true })

-- ========== AIMBOT HC CONDITIONS (global defaults) ==========
bs_v718.hc_conditions = bs_v601:switch("\v\f<crosshairs>\r  HC Conditions (Global)"):depend({ bs_v698, bs_v654 })

bs_v718.hc_conditions_gear = bs_v718.hc_conditions:create()
-- Condition-based HC overrides (aimbot-level, not per-player)
-- Structure: selectable of states -> weapon list -> per-weapon HC slider
bs_v718.hc_cond_gear = bs_v718.hc_conditions:create()
bs_v718.hc_cond_state_list = bs_v718.hc_cond_gear:combo("State", { "No Scope", "In Air", "LC/Defensive", "Standing", "Below", "Above", "Enemy HP", "Enemy Moving" }):depend({ bs_v718.hc_conditions, true })
bs_v718.hc_cond_state_en = {}
bs_v718.hc_cond_state_wlist = {}
bs_v718.hc_cond_state_wpn = {}
bs_v718.hc_cond_state_sl = {}
local bs_cond_states = { "noscope", "air", "lc", "stand", "below", "above", "enemyhp", "enemymove" }
local bs_cond_labels = { "No Scope", "In Air", "LC/Defensive", "Standing", "Below", "Above", "Enemy HP", "Enemy Moving" }
for ci, cstate in ipairs(bs_cond_states) do
	bs_v718.hc_cond_state_en[cstate] = bs_v718.hc_cond_gear:switch(bs_cond_labels[ci] .. " Enable"):depend({ bs_v718.hc_conditions, true }, { bs_v718.hc_cond_state_list, bs_cond_labels[ci] })
	bs_v718.hc_cond_state_wlist[cstate] = bs_v718.hc_cond_gear:list(cstate .. " Weapon", { "awp", "auto", "scout" }):depend({ bs_v718.hc_conditions, true }, { bs_v718.hc_cond_state_list, bs_cond_labels[ci] }, { bs_v718.hc_cond_state_en[cstate], true })
	bs_v718.hc_cond_state_wpn[cstate] = {}
	bs_v718.hc_cond_state_sl[cstate] = {}
	local widx = 0
	for _, hw in ipairs({ { key = "awp", label = "AWP" }, { key = "auto", label = "Auto" }, { key = "scout", label = "Scout" } }) do
		widx = widx + 1
		bs_v718.hc_cond_state_wpn[cstate][hw.key] = bs_v718.hc_cond_gear:switch("   " .. hw.label .. " Enable"):depend({ bs_v718.hc_conditions, true }, { bs_v718.hc_cond_state_list, bs_cond_labels[ci] }, { bs_v718.hc_cond_state_en[cstate], true }, { bs_v718.hc_cond_state_wlist[cstate], widx })
		bs_v718.hc_cond_state_sl[cstate][hw.key] = bs_v718.hc_cond_gear:slider("   " .. hw.label .. " HC", 0, 100, 0, 1, function(v) if v == 0 then return "OFF" end return v .. "%" end):depend({ bs_v718.hc_conditions, true }, { bs_v718.hc_cond_state_list, bs_cond_labels[ci] }, { bs_v718.hc_cond_state_en[cstate], true }, { bs_v718.hc_cond_state_wlist[cstate], widx }, { bs_v718.hc_cond_state_wpn[cstate][hw.key], true })
	end
end
-- Enemy HP threshold slider (global, used by "Enemy HP" condition)
bs_v718.hc_cond_hp_threshold = {}
for _, hw in ipairs({ { key = "awp", label = "AWP", widx = 1 }, { key = "auto", label = "Auto", widx = 2 }, { key = "scout", label = "Scout", widx = 3 } }) do
	bs_v718.hc_cond_hp_threshold[hw.key] = bs_v718.hc_cond_gear:slider("Enemy HP Threshold " .. hw.label, 0, 100, 50, 1):depend({ bs_v718.hc_conditions, true }, { bs_v718.hc_cond_state_list, "Enemy HP" }, { bs_v718.hc_cond_state_en["enemyhp"], true }, { bs_v718.hc_cond_state_wlist["enemyhp"], hw.widx }, { bs_v718.hc_cond_state_wpn["enemyhp"][hw.key], true })
end

bs_v621.aimbot = bs_v718

-- ========== MOVEMENT & ANIMATION TAB ==========
bs_v731 = {
	fall_damage = bs_v601:switch("\v\f<helmet-safety>\r  Avoid Fall Damage"):depend({ bs_v698, bs_v663 }),
	fast_ladder = bs_v601:switch("\v\f<arrow-right-arrow-left>\r  Fast Ladder"):depend({ bs_v698, bs_v663 }),
	anim_breaker = bs_v601:switch("\v\f<person-running>\r  Anim Breaker"):depend({ bs_v698, bs_v663 }),
	unlock_fd_speed = bs_v601:switch("\v\f<gauge-high>\r  Unlock FD Speed"):depend({ bs_v698, bs_v671 }),
	super_toss = bs_v601:switch("\v\f<person-running>\r  Straight Throw (Super Toss)"):depend({ bs_v698, bs_v671 }),
}
bs_v742 = bs_v731.anim_breaker:create()
bs_v731.types = bs_v742:selectable(bs_fmt("type"), {
	"in air",
	"on ground",
	"pitch zero on land"
}):depend({ bs_v731.anim_breaker, true })
bs_v731.in_air_type = bs_v742:combo(bs_fmt("in air"), {
	"static",
	"reverse running"
}, "static"):depend({ bs_v731.anim_breaker, true }, { bs_v731.types, "in air" })
bs_v731.on_ground_type = bs_v742:combo(bs_fmt("on ground"), {
	"static",
	"jitter",
	"reverse running"
}, "static"):depend({ bs_v731.anim_breaker, true }, { bs_v731.types, "on ground" })

bs_v621.movement = bs_v731

-- ========== EXTRAS TAB ==========
bs_v762 = {
	enabled = bs_v601:switch("\v\f<wine-bottle>\r  Drink"):depend({ bs_v698, bs_v680 }),
}
bs_v7 = bs_v762.enabled:create()
bs_v762.esp = bs_v7:switch(bs_fmt("show esp"), true):depend({ bs_v762.enabled, true })
bs_v762.esp_color = bs_v7:color_picker(bs_fmt("color"), color(255, 255, 255, 255)):depend({ bs_v762.enabled, true }, { bs_v762.esp, true })
bs_v762.distance = bs_v7:slider(bs_fmt("esp distance"), 50, 1500, 800, 1, "u"):depend({ bs_v762.enabled, true }, { bs_v762.esp, true })
bs_v621.drink = bs_v762

bs_v777 = {
	enabled = bs_v601:switch("\v\f<ruler>\r  Dist Flag"):depend({ bs_v698, bs_v680 }),
}
bs_v778 = bs_v777.enabled:create()
bs_v777.esp = bs_v778:switch(bs_fmt("show"), true):depend({ bs_v777.enabled, true })
bs_v621.dist_flag = bs_v777

bs_v21 = {
	enabled = bs_v601:switch("\v\f<tag>\r  Clantag"):depend({ bs_v698, bs_v680 }),
}
bs_v621.clantag = bs_v21

bs_v34 = {
	enabled = bs_v601:switch("\v\f<comment>\r  Kill Say"):depend({ bs_v698, bs_v680 }),
}
bs_v48 = bs_v34.enabled:create()
bs_v34.modes = bs_v48:selectable(bs_fmt("trigger on"), {
	"kill",
	"revenge"
}):depend({ bs_v34.enabled, true })
bs_v621.killsay = bs_v34

bs_menu.misc = bs_v621
bs_v640 = bs_pui.create(bs_menu_icons.visuals, " \n", 1)
bs_v479 = bs_v640:color_picker("accent color", color(107, 112, 147, 255)):depend({
	bs_v564,
	bs_v555
})
	bs_v480 = bs_v640:switch("Share Logo", false):depend({
	bs_v564,
	bs_v555
})

bs_pui.create(bs_menu_icons.visuals, " \n ", 2):label("\v✦\r  \aFFFFFFFFbluesense \a444444FF— 2026")
bs_pui.create(bs_menu_icons.misc, "  ", 2):label("\v✦\r  \aFFFFFFFFbluesense \a444444FF— 2026")

bs_v483 = nil
bs_v486 = false
bs_v489 = false
bs_v492 = nil
bs_v495 = false
bs_v499 = nil

function bs_v504()
	local var_90_0 = bs_config.visuals.weapon_chams

	if not var_90_0 then
		return
	end

	if bs_v499 then
		pcall(function()
			bs_v499:override()
		end)
	end

	if bs_v492 ~= nil then
		var_90_0:override(bs_v492)
	else
		var_90_0:override()
	end

	bs_v495 = false
end

function bs_v508()
	local var_92_0 = bs_config.visuals.weapon_chams

	if not var_92_0 then
		return
	end

	var_92_0:override(true)

	if not bs_v499 then
		pcall(function()
			bs_v499 = ui.find("Visuals", "Players", "Self", "Chams", "Weapon", "Color")
		end)
	end

	if bs_v499 then
		pcall(function()
			bs_v499:override(color("#6E96F000"))
		end)
	end

	bs_v495 = true
end

function bs_v513()
	local var_95_0 = bs_config.visuals.weapon_chams

	if not var_95_0 then
		return
	end

	if bs_v499 then
		pcall(function()
			bs_v499:override()
		end)
	end

	if bs_v492 ~= nil then
		var_95_0:override(bs_v492)
	else
		var_95_0:override()
	end

	bs_v495 = false
end

events.createmove(function(arg_97_0)
	local var_97_0 = bs_menu.info.additions

	if not var_97_0 then
		return
	end

	if var_97_0.remove_shadow:get() then
		cvar.cl_csm_shadows:int(0)

		bs_v486 = true
	elseif bs_v486 then
		cvar.cl_csm_shadows:int(1)

		bs_v486 = false
	end

	local var_97_1 = var_97_0.remove_weapon:get()
	local var_97_2 = bs_config.visuals.weapon_chams
	local var_97_3 = bs_config.visuals.thirdperson

	if not var_97_2 or not var_97_3 then
		bs_v489 = false

		return
	end

	if bs_v489 and not var_97_1 then
		bs_v489 = false

		bs_v504()

		bs_v492 = nil

		return
	end

	if not bs_v489 and var_97_1 then
		bs_v489 = true

		local var_97_4, var_97_5 = pcall(function()
			return var_97_2:get()
		end)

		bs_v492 = var_97_4 and var_97_5 or nil
	end

	if not var_97_1 then
		return
	end

	if var_97_3:get() or false then
		if not bs_v495 then
			bs_v508()
		end
	elseif bs_v495 then
		bs_v513()
	end
end)
events.shutdown(function()
	if bs_v486 then
		pcall(function()
			cvar.cl_csm_shadows:int(1)
		end)
	end

	if bs_v489 then
		pcall(function()
			bs_v504()
		end)
	end
end)

bs_v485 = nil
bs_v488 = nil

events.override_view(function(arg_102_0)
	local var_102_0 = bs_menu.info.scope_zoom

	if not var_102_0 or not var_102_0.enabled:get() then
		bs_v488 = nil

		return
	end

	local var_102_1 = entity.get_local_player()

	if not var_102_1 or not var_102_1:is_alive() then
		bs_v488 = nil

		return
	end

	local var_102_2 = arg_102_0.fov

	if bs_v488 == nil then
		bs_v488 = var_102_2

		return
	end

	local var_102_3 = 0.095 * (var_102_0.speed:get() / 100) * (globals.frametime * 175)
	local var_102_4 = math.max(0.001, math.min(1, var_102_3))

	if math.abs(var_102_2 - bs_v488) <= 0.095 then
		bs_v488 = var_102_2
	else
		bs_v488 = bs_v488 + (var_102_2 - bs_v488) * var_102_4
	end

	arg_102_0.fov = bs_v488
end)

bs_v487 = nil
bs_v491 = nil
bs_v494 = nil
bs_v498 = nil
bs_v503 = nil
bs_v507 = nil
bs_v512 = nil
bs_v517 = false

function bs_v521()
	if bs_v507 then
		return
	end

	pcall(function()
		bs_v507 = ui.find("Visuals", "World", "Main", "Override Zoom", "Force Viewmodel")
	end)
end

function bs_v526()
	if not bs_v507 then
		return
	end

	if not bs_v517 then
		if bs_v512 == nil then
			pcall(function()
				bs_v512 = bs_v507:get()
			end)
		end

		bs_v517 = true
	end

	pcall(function()
		bs_v507:override(true)
	end)
end

function bs_v531()
	if not bs_v507 then
		return
	end

	if not bs_v517 then
		return
	end

	bs_v507:override()

	if bs_v512 ~= nil then
		pcall(function()
			bs_v507:set(bs_v512)
		end)
	end

	bs_v517 = false
end

events.render(function()
	bs_v521()

	local var_110_0 = bs_menu.info.viewmodel

	if not var_110_0 or not var_110_0.enabled:get() then
		if bs_v491 ~= nil then
			pcall(function()
				cvar.viewmodel_fov:float(68, true)
			end)
			pcall(function()
				cvar.viewmodel_offset_x:float(0, true)
			end)
			pcall(function()
				cvar.viewmodel_offset_y:float(0, true)
			end)
			pcall(function()
				cvar.viewmodel_offset_z:float(0, true)
			end)
		end

		bs_v491 = nil
		bs_v494 = nil
		bs_v498 = nil
		bs_v503 = nil

		bs_v531()

		return
	end

	local var_110_1 = math.max(0.001, math.min(globals.frametime, 0.05))
	local var_110_2 = math.min(1, var_110_1 * 12)
	local var_110_3 = var_110_0.fov:get()
	local var_110_4 = var_110_0.x:get() * 0.1
	local var_110_5 = var_110_0.y:get() * 0.1
	local var_110_6 = var_110_0.z:get() * 0.1

	if var_110_0.viewmodel_in_scope and var_110_0.viewmodel_in_scope:get() then
		bs_v526()

		local var_110_7 = entity.get_local_player()

		if var_110_7 and var_110_7:is_alive() and (pcall(function()
			return var_110_7.m_bIsScoped
		end) and var_110_7.m_bIsScoped or false) then
			var_110_4 = var_110_0.scope_x:get() * 0.1
			var_110_5 = var_110_0.scope_y:get() * 0.1
			var_110_6 = var_110_0.scope_z:get() * 0.1

			local var_110_8 = var_110_0.scope_anim_speed:get() * 0.1

			var_110_2 = math.min(1, var_110_1 * var_110_8)
		end
	else
		bs_v531()
	end

	if bs_v491 == nil then
		bs_v491 = var_110_3
	end

	if bs_v494 == nil then
		bs_v494 = var_110_4
	end

	if bs_v498 == nil then
		bs_v498 = var_110_5
	end

	if bs_v503 == nil then
		bs_v503 = var_110_6
	end

	bs_v491 = bs_v491 + (var_110_3 - bs_v491) * var_110_2
	bs_v494 = bs_v494 + (var_110_4 - bs_v494) * var_110_2
	bs_v498 = bs_v498 + (var_110_5 - bs_v498) * var_110_2
	bs_v503 = bs_v503 + (var_110_6 - bs_v503) * var_110_2

	pcall(function()
		cvar.viewmodel_fov:float(bs_v491, true)
	end)
	pcall(function()
		cvar.viewmodel_offset_x:float(bs_v494, true)
	end)
	pcall(function()
		cvar.viewmodel_offset_y:float(bs_v498, true)
	end)
	pcall(function()
		cvar.viewmodel_offset_z:float(bs_v503, true)
	end)
end)

bs_v490 = nil
bs_v493 = bs_smoothy.new(0)
bs_v497 = bs_smoothy.new(0)
bs_v502 = nil
bs_v506 = nil
bs_v511 = false

function bs_v516()
	if bs_v502 then
		return
	end

	pcall(function()
		bs_v502 = ui.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay")
	end)
end

function bs_v520()
	if bs_v502 and bs_v506 == nil then
		pcall(function()
			bs_v506 = bs_v502:get()
		end)
	end
end

function bs_v525()
	if not bs_v502 then
		return
	end

	if not bs_v511 then
		return
	end

	bs_v502:override()

	if bs_v506 ~= nil then
		pcall(function()
			bs_v502:set(bs_v506)
		end)
	end

	bs_v511 = false
end

function bs_v530()
	if not bs_v502 then
		return
	end

	bs_v520()
	bs_v502:override("Remove All")

	bs_v511 = true
end

bs_v516()
events.render(function()
	bs_v516()

	bs_v768 = entity.get_local_player()

	if bs_v768 == nil or not bs_v768:is_alive() then
		bs_v493(0.05, false)
		bs_v497(0.05, false)
		bs_v525()

		return
	end

	if bs_v768:get_player_weapon() == nil then
		bs_v493(0.05, false)
		bs_v497(0.05, false)
		bs_v525()

		return
	end

	bs_v774 = bs_menu.info.custom_scope
	bs_v779 = bs_v774 and bs_v774.enabled and bs_v774.enabled:get()
	bs_v780 = bs_v768.m_bIsScoped

	if bs_v774.disable_animation and bs_v774.disable_animation:get() then
		bs_v493.value = bs_v779 and 1 or 0
		bs_v497.value = bs_v779 and bs_v780 and 1 or 0
	else
		bs_v782 = (bs_v774.anim_speed and bs_v774.anim_speed:get() or 5) * 0.01

		bs_v493(bs_v782, bs_v779)
		bs_v497(bs_v782, bs_v779 and bs_v780)
	end

	if bs_v493.value <= 0 then
		bs_v525()

		return
	end

	bs_v530()

	bs_v781 = bs_v493.value * bs_v497.value
	bs_v783 = render.screen_size()
	bs_v784 = bs_v783 * 0.5
	bs_v785 = math.floor(bs_v774.gap:get() * bs_v783.y * (1 / bs_v783.y))
	bs_v786 = math.floor(bs_v774.length:get() * bs_v783.y * (1 / bs_v783.y))
	bs_v769 = bs_v786 - bs_v785
	bs_v770 = bs_v774.color_main:get()
	bs_v771 = bs_v774.color_edge:get()
	bs_v770.a = bs_v770.a * bs_v781
	bs_v771.a = bs_v771.a * bs_v781

	if bs_v774.glow and bs_v774.glow:get() then
		bs_v772 = bs_v774.glow_color:get()
		bs_v773 = {
			{
				a_mul = 0.05,
				w = 7
			},
			{
				a_mul = 0.1,
				w = 4
			},
			{
				a_mul = 0.18,
				w = 2
			}
		}

		for iter_127_0, iter_127_1 in ipairs(bs_v773) do
			bs_v775 = math.floor(bs_v772.a * bs_v781 * iter_127_1.a_mul)

			if bs_v775 > 1 then
				bs_v776 = iter_127_1.w
				local bs_v777 = color(bs_v772.r, bs_v772.g, bs_v772.b, bs_v775)
				bs_v778 = color(bs_v772.r, bs_v772.g, bs_v772.b, 0)

				render.gradient(vector(bs_v784.x - bs_v776, bs_v784.y - bs_v785 + 1), vector(bs_v784.x + 1 + bs_v776, bs_v784.y - bs_v786 * bs_v781), bs_v777, bs_v777, bs_v778, bs_v778)
				render.gradient(vector(bs_v784.x - bs_v776, bs_v784.y + bs_v785), vector(bs_v784.x + 1 + bs_v776, bs_v784.y + bs_v786 * bs_v781), bs_v777, bs_v777, bs_v778, bs_v778)
				render.gradient(vector(bs_v784.x - bs_v785 + 1, bs_v784.y - bs_v776), vector(bs_v784.x - bs_v785 + 1 - bs_v769 * bs_v781, bs_v784.y + 1 + bs_v776), bs_v777, bs_v778, bs_v777, bs_v778)
				render.gradient(vector(bs_v784.x + bs_v785, bs_v784.y - bs_v776), vector(bs_v784.x + bs_v785 + bs_v769 * bs_v781 + 1, bs_v784.y + 1 + bs_v776), bs_v777, bs_v778, bs_v777, bs_v778)
			end
		end
	end

	render.gradient(vector(bs_v784.x, bs_v784.y - bs_v785 + 1), vector(bs_v784.x + 1, bs_v784.y - bs_v786 * bs_v781), bs_v770, bs_v770, bs_v771, bs_v771)
	render.gradient(vector(bs_v784.x, bs_v784.y + bs_v785), vector(bs_v784.x + 1, bs_v784.y + bs_v786 * bs_v781), bs_v770, bs_v770, bs_v771, bs_v771)
	render.gradient(vector(bs_v784.x - bs_v785 + 1, bs_v784.y), vector(bs_v784.x - bs_v785 + 1 - bs_v769 * bs_v781, bs_v784.y + 1), bs_v770, bs_v771, bs_v770, bs_v771)
	render.gradient(vector(bs_v784.x + bs_v785, bs_v784.y), vector(bs_v784.x + bs_v785 + bs_v769 * bs_v781 + 1, bs_v784.y + 1), bs_v770, bs_v771, bs_v770, bs_v771)
end)

bs_notify = {}
bs_v496 = {}
bs_v501 = 12
bs_v505 = 7
bs_v510 = 9
bs_v515 = 6
bs_v519 = 11
bs_v524 = 6
bs_v529 = 9
bs_v534 = 10
bs_v537 = 2
bs_v541 = 3.5
bs_v548 = 6
bs_v563 = ui.create("DRAGGING_notifications"):slider("notifications:y", -16384, 16384, 0)

bs_v563:visibility(false)
bs_add_round_cb(function()
	bs_v563:set(0)
end)
table.insert(bs_reset_cbs, {
	key = "ntf:y",
	get = function()
		return bs_v563:get()
	end,
	set = function(arg_130_0)
		bs_v563:set(arg_130_0)
	end
})

bs_v575 = {
	drag_start_y = 0,
	grab_anim = 0,
	hover_anim = 0,
	dragging = false,
	drag_start_val = 0
}

function bs_v581(arg_131_0)
	return arg_131_0.y - 52 + bs_v563:get()
end

function bs_v589(arg_132_0)
	return arg_132_0.prefix_mode:get() == "icon"
end

function bs_v594(arg_133_0)
	if arg_133_0 and arg_133_0.font then
		local var_133_0, var_133_1 = pcall(function()
			return arg_133_0.font:get()
		end)

		if var_133_0 and var_133_1 == "verdana" then
			return bs_font_10b, bs_font_14b
		end
	end

	return bs_font_10, bs_font_14
end

function bs_v600(arg_135_0, arg_135_1, arg_135_2, arg_135_3)
	local var_135_0, var_135_1 = bs_v594(arg_135_3)
	local var_135_2 = arg_135_2 and var_135_1 or var_135_0
	local var_135_3

	if arg_135_2 then
		var_135_3 = render.measure_text(var_135_2, nil, arg_135_1).x
	else
		var_135_3 = render.measure_text(var_135_2, nil, arg_135_1).x + bs_v537 * (#arg_135_1 - 1)
	end

	local var_135_4 = var_135_3 + bs_v519 * 2
	local var_135_5 = 0

	for iter_135_0, iter_135_1 in ipairs(arg_135_0) do
		var_135_5 = var_135_5 + render.measure_text(var_135_0, nil, tostring(iter_135_1)).x
	end

	local var_135_6 = var_135_5 + bs_v534 * 2
	local var_135_7 = render.measure_text(var_135_2, nil, "A").y

	return var_135_4 + bs_v524 + var_135_6, var_135_7 + bs_v505 * 2
end

function bs_v610(arg_136_0, arg_136_1, arg_136_2)
	return {
		slide_hiding = false,
		fut_hiding = false,
		old_hiding = false,
		dying = false,
		parts = arg_136_0,
		accent = arg_136_1,
		has_custom_accent = arg_136_1 ~= nil,
		born = globals.realtime,
		dur = arg_136_2 or bs_v541,
		alife = bs_smoothy.new(0),
		adie = bs_smoothy.new(0),
		old_fraction = bs_smoothy.new(0),
		old_adder = bs_smoothy.new(1),
		old_size = bs_smoothy.new(0),
		fut_fraction = bs_smoothy.new(0),
		fut_adder = bs_smoothy.new(0),
		fut_blur_in = bs_smoothy.new(0),
		fut_blur_out = bs_smoothy.new(0),
		slide_alpha = bs_smoothy.new(0),
		slide_adder = bs_smoothy.new(0)
	}
end

function bs_notify.new(arg_137_0, arg_137_1)
	local var_137_0 = type(arg_137_0) == "table" and arg_137_0 or {
		arg_137_0
	}
	local var_137_1 = 0

	for iter_137_0, iter_137_1 in ipairs(bs_v496) do
		if not iter_137_1.dying then
			var_137_1 = var_137_1 + 1
		end
	end

	if var_137_1 >= bs_v548 then
		for iter_137_2, iter_137_3 in ipairs(bs_v496) do
			if not iter_137_3.dying then
				iter_137_3.dying = true
				iter_137_3.born = 0

				break
			end
		end
	end

	local var_137_2 = bs_v610(var_137_0, arg_137_1)

	table.insert(bs_v496, var_137_2)

	return var_137_2
end

bs_v620 = {}
bs_v639 = {}
bs_v651 = 0
bs_v659 = 1.8
bs_v667 = 3

;(function()
	bs_v639 = {
		{
			ptype = "abf_miss",
			parts = {
				"anti-bruteforce triggered by ",
				"bluesense",
				" due to ",
				"miss",
				" impact - angle shifted"
			},
			clr = color(150, 195, 255, 255)
		},
		{
			ptype = "abf_hit",
			parts = {
				"anti-bruteforce triggered by ",
				"bluesense",
				" due to ",
				"hit",
				" impact - angle shifted"
			},
			clr = color(255, 160, 80, 255)
		},
		{
			ptype = "hit",
			parts = {
				"hit ",
				"bluesense",
				" for ",
				"100",
				" hp"
			},
			clr = color(125, 210, 125, 255)
		},
		{
			ptype = "miss",
			parts = {
				"missed ",
				"bluesense",
				" in ",
				"head",
				" due to ",
				"correction"
			},
			clr = color(220, 80, 80, 255)
		}
	}
end)()

bs_v683 = 1

function bs_v692()
	local var_139_0 = bs_v639[bs_v683]

	bs_v683 = bs_v683 % #bs_v639 + 1

	local var_139_1 = 0

	for iter_139_0, iter_139_1 in ipairs(bs_v620) do
		if not iter_139_1.dying then
			var_139_1 = var_139_1 + 1
		end
	end

	if var_139_1 >= bs_v548 then
		for iter_139_2, iter_139_3 in ipairs(bs_v620) do
			if not iter_139_3.dying then
				iter_139_3.dying = true
				iter_139_3.born = 0

				break
			end
		end
	end

	local var_139_2 = bs_menu.info.notify

	if not var_139_2 then
		return
	end

	local var_139_3 = var_139_0.clr

	if var_139_0.ptype == "hit" then
		var_139_3 = var_139_2.col_hit:get()
	elseif var_139_0.ptype == "miss" then
		var_139_3 = var_139_2.col_miss:get()
elseif var_139_0.ptype == "abf_miss" then
		var_139_3 = var_139_2.col_abf_miss and var_139_2.col_abf_miss:get() or color(255, 0, 0, 255)
	 elseif var_139_0.ptype == "abf_hit" then
		var_139_3 = var_139_2.col_abf_hit and var_139_2.col_abf_hit:get() or color(0, 255, 0, 255)
	end

	table.insert(bs_v620, bs_v610(var_139_0.parts, var_139_3, bs_v667))
end

function bs_v703(arg_140_0, arg_140_1, arg_140_2, arg_140_3, arg_140_4, arg_140_5, arg_140_6)
	local var_140_0 = 6
	local var_140_1 = 1 / var_140_0
	local var_140_2 = 1

	for iter_140_0 = 1, var_140_0 do
		local var_140_3 = math.floor(arg_140_4.a * arg_140_5 * var_140_2 * 0.35)

		if var_140_3 > 1 then
			render.rect_outline(vector(arg_140_0 - iter_140_0, arg_140_1 - iter_140_0), vector(arg_140_2 + iter_140_0, arg_140_3 + iter_140_0), color(arg_140_4.r, arg_140_4.g, arg_140_4.b, var_140_3), 1, arg_140_6 + iter_140_0)
		end

		var_140_2 = var_140_2 - var_140_1
	end
end

function bs_v713(arg_141_0, arg_141_1, arg_141_2, arg_141_3, arg_141_4, arg_141_5, arg_141_6)
	bs_v811 = arg_141_0.col_glass:get()
	bs_v812 = arg_141_0.col_border:get()
	bs_v813 = arg_141_1.has_custom_accent and arg_141_1.accent or arg_141_0.col_accent:get()
	bs_v787 = arg_141_0.col_accent:get()
	bs_v788 = arg_141_0.col_text:get()
	bs_v789 = math.floor(arg_141_6 * 255)
	bs_v790 = arg_141_0.blur:get()
	bs_v791 = bs_v589(arg_141_0)
	bs_v792 = bs_v791 and "✦" or "bluesense"
	bs_v793, bs_v794 = bs_v594(arg_141_0)
	bs_v795 = bs_v791 and bs_v794 or bs_v793
	bs_v796 = nil

	if bs_v791 then
		bs_v796 = render.measure_text(bs_v795, nil, bs_v792).x
	else
		bs_v796 = render.measure_text(bs_v795, nil, bs_v792).x + bs_v537 * (#bs_v792 - 1)
	end

	bs_v797 = bs_v796 + bs_v519 * 2
	bs_v798 = arg_141_2 + bs_v797 + bs_v524
	bs_v799 = arg_141_4 - bs_v797 - bs_v524
	bs_v800 = math.floor(bs_v789 * 0.18)

	if bs_v800 > 1 then
		render.rect(vector(arg_141_2 - 2, arg_141_3 - 1), vector(arg_141_2 + bs_v797 + 2, arg_141_3 + arg_141_5 + 3), color(0, 0, 0, bs_v800), bs_v529 + 2)
	end

	if bs_v790 and bs_v789 > 10 then
		render.blur(vector(arg_141_2, arg_141_3), vector(arg_141_2 + bs_v797, arg_141_3 + arg_141_5), 6, arg_141_6 * 0.85, bs_v529)
		render.blur(vector(arg_141_2, arg_141_3), vector(arg_141_2 + bs_v797, arg_141_3 + arg_141_5), 3, arg_141_6 * 0.55, bs_v529)
		render.blur(vector(arg_141_2, arg_141_3), vector(arg_141_2 + bs_v797, arg_141_3 + arg_141_5), 1, arg_141_6 * 0.3, bs_v529)
	end

	render.rect(vector(arg_141_2, arg_141_3), vector(arg_141_2 + bs_v797, arg_141_3 + arg_141_5), color(bs_v811.r, bs_v811.g, bs_v811.b, math.floor(bs_v811.a * arg_141_6)), bs_v529)

	if arg_141_0.glow and arg_141_0.glow:get() then
		bs_v703(arg_141_2, arg_141_3, arg_141_2 + bs_v797, arg_141_3 + arg_141_5, bs_v813, arg_141_6 * 0.8, bs_v529)
	end

	render.rect(vector(arg_141_2 + 1, arg_141_3 + 1), vector(arg_141_2 + bs_v797 - 1, arg_141_3 + 1 + math.floor(arg_141_5 * 0.4)), color(255, 255, 255, math.floor(bs_v789 * 0.07)), bs_v529)
	render.rect_outline(vector(arg_141_2, arg_141_3), vector(arg_141_2 + bs_v797, arg_141_3 + arg_141_5), color(bs_v812.r, bs_v812.g, bs_v812.b, math.floor(bs_v812.a * arg_141_6)), 1, bs_v529)

	bs_v801 = render.measure_text(bs_v795, nil, "A").y
	bs_v802 = arg_141_3 + math.floor((arg_141_5 - bs_v801) * 0.5)
	bs_v803 = arg_141_2 + math.floor((bs_v797 - bs_v796) * 0.5)

	if bs_v791 then
		render.text(bs_v795, vector(bs_v803, bs_v802), color(bs_v787.r, bs_v787.g, bs_v787.b, math.floor(bs_v787.a * arg_141_6)), nil, bs_v792)
	else
		bs_v805 = bs_v803

		for iter_141_0 = 1, #bs_v792 do
			bs_v808 = bs_v792:sub(iter_141_0, iter_141_0)
			bs_v809 = render.measure_text(bs_v795, nil, bs_v808).x

			render.text(bs_v795, vector(bs_v805, bs_v802), color(bs_v787.r, bs_v787.g, bs_v787.b, math.floor(bs_v787.a * arg_141_6)), nil, bs_v808)

			bs_v805 = bs_v805 + bs_v809 + (iter_141_0 < #bs_v792 and bs_v537 or 0)
		end
	end

	if bs_v800 > 1 then
		render.rect(vector(bs_v798 - 2, arg_141_3 - 1), vector(bs_v798 + bs_v799 + 2, arg_141_3 + arg_141_5 + 3), color(0, 0, 0, bs_v800), bs_v529 + 2)
	end

	if bs_v790 and bs_v789 > 10 then
		render.blur(vector(bs_v798, arg_141_3), vector(bs_v798 + bs_v799, arg_141_3 + arg_141_5), 4, arg_141_6 * 0.72, bs_v529)
	end

	render.rect(vector(bs_v798, arg_141_3), vector(bs_v798 + bs_v799, arg_141_3 + arg_141_5), color(bs_v811.r, bs_v811.g, bs_v811.b, math.floor(bs_v811.a * arg_141_6)), bs_v529)

	if arg_141_0.glow and arg_141_0.glow:get() then
		bs_v703(bs_v798, arg_141_3, bs_v798 + bs_v799, arg_141_3 + arg_141_5, bs_v813, arg_141_6 * 0.8, bs_v529)
	end

	render.rect(vector(bs_v798 + 1, arg_141_3 + 1), vector(bs_v798 + bs_v799 - 1, arg_141_3 + 1 + math.floor(arg_141_5 * 0.4)), color(255, 255, 255, math.floor(bs_v789 * 0.07)), bs_v529)
	render.rect_outline(vector(bs_v798, arg_141_3), vector(bs_v798 + bs_v799, arg_141_3 + arg_141_5), color(bs_v812.r, bs_v812.g, bs_v812.b, math.floor(bs_v812.a * arg_141_6)), 1, bs_v529)

	bs_v804 = render.measure_text(bs_v793, nil, "A").y
	bs_v806 = arg_141_3 + math.floor((arg_141_5 - bs_v804) * 0.5)
	bs_v807 = bs_v798 + bs_v534

	for iter_141_1, iter_141_2 in ipairs(arg_141_1.parts) do
		bs_v810 = iter_141_1 % 2 == 1 and bs_v788 or bs_v813

		render.text(bs_v793, vector(bs_v807, bs_v806), color(bs_v810.r, bs_v810.g, bs_v810.b, math.floor(bs_v810.a * arg_141_6)), nil, tostring(iter_141_2))

		bs_v807 = bs_v807 + render.measure_text(bs_v793, nil, tostring(iter_141_2)).x
	end
end

function bs_v724(arg_142_0, arg_142_1, arg_142_2, arg_142_3)
	if not (globals.realtime < arg_142_0.born + arg_142_0.dur) then
		arg_142_0.old_hiding = true
	end

	local var_142_0 = arg_142_0.old_fraction(0.06, arg_142_0.old_hiding and 0 or 1)

	if var_142_0 <= 0.005 then
		return true, 0
	end

	local var_142_1 = bs_v589(arg_142_3)
	local var_142_2 = var_142_1 and "✦" or "bluesense"
	local var_142_3, var_142_4 = bs_v600(arg_142_0.parts, var_142_2, var_142_1, arg_142_3)
	local var_142_5 = arg_142_0.old_adder(0.06, arg_142_0.old_hiding and 0 or 1)
	local var_142_6 = (1 - var_142_5) * (var_142_4 + 14)
	local var_142_7 = math.floor(arg_142_1 - var_142_3 * 0.5)
	local var_142_8 = math.floor(arg_142_2 + var_142_6)

	bs_v713(arg_142_3, arg_142_0, var_142_7, var_142_8, var_142_3, var_142_4, var_142_0)

	local var_142_9 = arg_142_3.glow and arg_142_3.glow:get() and 14 or bs_v515

	return false, (var_142_4 + var_142_9) * var_142_5
end

function bs_v737(arg_143_0, arg_143_1, arg_143_2, arg_143_3)
	if not arg_143_0.fut_hiding and globals.realtime >= arg_143_0.born + arg_143_0.dur then
		arg_143_0.fut_hiding = true
	end

	bs_v822 = arg_143_0.fut_hiding and 0 or 1
	bs_v823 = arg_143_0.fut_blur_in(0.08, bs_v822)
	bs_v824 = arg_143_0.fut_adder(0.08, bs_v822)

	if arg_143_0.fut_hiding and bs_v823 < 0.004 then
		return true, 0
	end

	bs_v825 = bs_v589(arg_143_3)
	bs_v826 = bs_v825 and "✦" or "bluesense"
	bs_v827, bs_v814 = bs_v600(arg_143_0.parts, bs_v826, bs_v825, arg_143_3)
	bs_v815 = (1 - bs_v823) * 6
	bs_v816 = math.floor(arg_143_1 - bs_v827 * 0.5)
	bs_v817 = math.floor(arg_143_2 + bs_v815)
	bs_v818 = math.floor(bs_v823 * 255)

	if bs_v818 < 2 then
		return false, (bs_v814 + bs_v515) * bs_v824
	end

	bs_v819 = arg_143_3.col_glass:get()
	bs_v820 = arg_143_3.col_border:get()

	render.rect(vector(bs_v816 - 1, bs_v817 + 2), vector(bs_v816 + bs_v827 + 1, bs_v817 + bs_v814 + 3), color(0, 0, 0, math.floor(bs_v818 * 0.18)), bs_v510 + 2)

	if arg_143_3.blur:get() and bs_v818 > 10 then
		render.blur(vector(bs_v816, bs_v817), vector(bs_v816 + bs_v827, bs_v817 + bs_v814), 4, bs_v823 * 0.72, bs_v510)
	end

	render.rect(vector(bs_v816, bs_v817), vector(bs_v816 + bs_v827, bs_v817 + bs_v814), color(bs_v819.r, bs_v819.g, bs_v819.b, math.floor(bs_v819.a * bs_v823)), bs_v510)
	render.rect(vector(bs_v816 + 1, bs_v817 + 1), vector(bs_v816 + bs_v827 - 1, bs_v817 + math.max(2, math.floor(bs_v814 * 0.35))), color(255, 255, 255, math.floor(bs_v818 * 0.06)), bs_v510)
	render.rect_outline(vector(bs_v816, bs_v817), vector(bs_v816 + bs_v827, bs_v817 + bs_v814), color(bs_v820.r, bs_v820.g, bs_v820.b, math.floor(bs_v820.a * bs_v823)), 1, bs_v510)

	bs_v821 = nil

	if not arg_143_0.fut_hiding then
		bs_v821 = math.max(0, (bs_v823 - 0.12) / 0.88)
	else
		bs_v821 = math.max(0, (bs_v823 - 0.08) / 0.92)
	end

	if bs_v821 > 0.01 then
		bs_v713(arg_143_3, arg_143_0, bs_v816, bs_v817, bs_v827, bs_v814, math.min(1, bs_v821))
	end

	return false, (bs_v814 + bs_v515) * bs_v824
end

function bs_v739(arg_144_0, arg_144_1, arg_144_2, arg_144_3)
	bs_v859 = globals.realtime

	if not arg_144_0.ntf_frac then
		arg_144_0.ntf_frac = bs_smoothy.new(0)
	end

	if not arg_144_0.ntf_adder then
		arg_144_0.ntf_adder = bs_smoothy.new(1)
	end

	if not arg_144_0.ntf_size then
		arg_144_0.ntf_size = bs_smoothy.new(0)
	end

	if not arg_144_0.ntf_hiding and bs_v859 >= arg_144_0.born + arg_144_0.dur then
		arg_144_0.ntf_hiding = true
	end

	bs_v864 = arg_144_0.ntf_frac(0.05, not arg_144_0.ntf_hiding)

	if bs_v864 <= 0.004 then
		return true, 0
	end

	bs_v865 = arg_144_0.ntf_adder(0.05, false)
	bs_v866 = bs_v589(arg_144_3)
	bs_v867 = bs_v866 and "✦" or "bluesense"
	bs_v868, bs_v828 = bs_v594(arg_144_3)
	bs_v829 = bs_v866 and bs_v828 or bs_v868
	bs_v830 = nil

	if bs_v866 then
		bs_v830 = render.measure_text(bs_v829, nil, bs_v867).x
	else
		bs_v830 = render.measure_text(bs_v829, nil, bs_v867).x + bs_v537 * (#bs_v867 - 1)
	end

	bs_v831 = bs_v830 + bs_v519 * 2
	bs_v832 = 0

	for iter_144_0, iter_144_1 in ipairs(arg_144_0.parts) do
		bs_v832 = bs_v832 + render.measure_text(bs_v868, nil, tostring(iter_144_1)).x
	end

	bs_v833 = bs_v832 + bs_v534 * 2 + 1
	bs_v834 = math.ceil(arg_144_0.ntf_size(0.05, not arg_144_0.ntf_hiding and bs_v833 or 0))
	bs_v835 = render.measure_text(bs_v829, nil, "A").y + bs_v505 * 2
	bs_v836 = bs_v831 + bs_v524 + bs_v834
	bs_v837 = math.floor(arg_144_1 - bs_v836 * 0.5)
	bs_v838 = math.floor(arg_144_2 - (bs_v835 + bs_v515) * bs_v865)
	bs_v839 = math.floor(255 * bs_v864)
	bs_v840 = arg_144_3.col_glass:get()
	bs_v841 = arg_144_3.col_border:get()
	bs_v842 = arg_144_0.has_custom_accent and arg_144_0.accent or arg_144_3.col_accent:get()
	bs_v843 = arg_144_3.col_accent:get()
	bs_v844 = arg_144_3.col_text:get()
	bs_v845 = arg_144_3.blur:get()
	bs_v846 = color(bs_v840.r, bs_v840.g, bs_v840.b, math.floor(math.max(bs_v840.a, 140) * bs_v864))
	bs_v847 = color(bs_v840.r, bs_v840.g, bs_v840.b, math.floor(math.max(bs_v840.a, 105) * bs_v864))
	bs_v848 = color(bs_v841.r, bs_v841.g, bs_v841.b, math.floor(bs_v841.a * bs_v864))
	bs_v849 = math.floor(bs_v839 * 0.16)

	if bs_v849 > 1 then
		render.rect(vector(bs_v837 - 2, bs_v838 + 2), vector(bs_v837 + bs_v831 + 2, bs_v838 + bs_v835 + 3), color(0, 0, 0, bs_v849), bs_v529 + 2)
	end

	if bs_v845 and bs_v839 > 8 then
		render.blur(vector(bs_v837, bs_v838), vector(bs_v837 + bs_v831, bs_v838 + bs_v835), 0, bs_v864, bs_v529)
	end

	render.rect(vector(bs_v837, bs_v838), vector(bs_v837 + bs_v831, bs_v838 + bs_v835), bs_v846, bs_v529)

	if arg_144_3.glow and arg_144_3.glow:get() then
		bs_v703(bs_v837, bs_v838, bs_v837 + bs_v831, bs_v838 + bs_v835, bs_v842, bs_v864 * 0.8, bs_v529)
	end

	render.rect_outline(vector(bs_v837, bs_v838), vector(bs_v837 + bs_v831, bs_v838 + bs_v835), bs_v848, 1, bs_v529)

	bs_v850 = render.measure_text(bs_v829, nil, "A").y
	bs_v851 = bs_v838 + math.floor((bs_v835 - bs_v850) * 0.5)
	bs_v852 = bs_v837 + math.floor((bs_v831 - bs_v830) * 0.5)

	if bs_v866 then
		render.text(bs_v829, vector(bs_v852, bs_v851), color(bs_v843.r, bs_v843.g, bs_v843.b, math.floor(bs_v843.a * bs_v864)), nil, bs_v867)
	else
		bs_v855 = bs_v852

		for iter_144_2 = 1, #bs_v867 do
			bs_v860 = bs_v867:sub(iter_144_2, iter_144_2)
			bs_v861 = render.measure_text(bs_v829, nil, bs_v860).x

			render.text(bs_v829, vector(bs_v855, bs_v851), color(bs_v843.r, bs_v843.g, bs_v843.b, math.floor(bs_v843.a * bs_v864)), nil, bs_v860)

			bs_v855 = bs_v855 + bs_v861 + (iter_144_2 < #bs_v867 and bs_v537 or 0)
		end
	end

	if bs_v834 > 1 then
		bs_v854 = bs_v837 + bs_v831 + bs_v524

		if bs_v849 > 1 then
			render.rect(vector(bs_v854 - 2, bs_v838 + 2), vector(bs_v854 + bs_v834 + 2, bs_v838 + bs_v835 + 3), color(0, 0, 0, bs_v849), bs_v529 + 2)
		end

		if bs_v845 and bs_v839 > 8 then
			render.blur(vector(bs_v854, bs_v838), vector(bs_v854 + bs_v834, bs_v838 + bs_v835), 0, bs_v864, bs_v529)
		end

		render.rect(vector(bs_v854, bs_v838), vector(bs_v854 + bs_v834, bs_v838 + bs_v835), bs_v847, bs_v529)

		if arg_144_3.glow and arg_144_3.glow:get() then
			bs_v703(bs_v854, bs_v838, bs_v854 + bs_v834, bs_v838 + bs_v835, bs_v842, bs_v864 * 0.8, bs_v529)
		end

		render.rect_outline(vector(bs_v854, bs_v838), vector(bs_v854 + bs_v834, bs_v838 + bs_v835), bs_v848, 1, bs_v529)

		bs_v856 = render.measure_text(bs_v868, nil, "A").y
		bs_v857 = bs_v838 + math.floor((bs_v835 - bs_v856) * 0.5)
		bs_v858 = bs_v854 + bs_v534

		render.push_clip_rect(vector(bs_v858, bs_v857), vector(bs_v854 + bs_v834 - bs_v534, bs_v857 + bs_v856 + 1))

		for iter_144_3, iter_144_4 in ipairs(arg_144_0.parts) do
			bs_v862 = iter_144_3 % 2 == 1 and bs_v844 or bs_v842
			bs_v863 = tostring(iter_144_4)

			render.text(bs_v868, vector(bs_v858, bs_v857), color(bs_v862.r, bs_v862.g, bs_v862.b, math.floor(bs_v862.a * bs_v864)), nil, bs_v863)

			bs_v858 = bs_v858 + render.measure_text(bs_v868, nil, bs_v863).x
		end

		render.pop_clip_rect()
	end

	bs_v853 = arg_144_3.glow and arg_144_3.glow:get() and 14 or bs_v515

	return false, (bs_v835 + bs_v853) * bs_v864
end

function bs_v752(arg_145_0, arg_145_1)
	if not arg_145_1 then
		bs_v575.dragging = false
		bs_v575.grab_anim = bs_v575.grab_anim + (0 - bs_v575.grab_anim) * 0.1

		return
	end

	local var_145_0 = false

	if bs_tab_dummy then
		local var_145_1, var_145_2 = pcall(function()
			return bs_tab_dummy:get()
		end)

		var_145_0 = var_145_1 and var_145_2 == 2
	end

	if not var_145_0 then
		bs_v575.dragging = false

		return
	end

	local var_145_3 = ui.get_mouse_position()
	local var_145_4 = common.is_button_down(1)
	local var_145_5 = arg_145_0.x * 0.5
	local var_145_6 = bs_v581(arg_145_0)
	local var_145_7 = 120
	local var_145_8 = 14

	if var_145_4 and not bs_confirm_anim.visible then
		if not bs_v575.dragging then
			if bs_scope_zoom == nil and var_145_3.x >= var_145_5 - var_145_7 * 0.5 and var_145_3.x <= var_145_5 + var_145_7 * 0.5 and var_145_3.y >= var_145_6 - var_145_8 and var_145_6 >= var_145_3.y then
				bs_v575.dragging = true
				bs_scope_zoom = bs_v575
				bs_v575.drag_start_y = var_145_3.y
				bs_v575.drag_start_val = bs_v563:get()
			end
		else
			local var_145_9 = bs_v575.drag_start_val + (var_145_3.y - bs_v575.drag_start_y)

			bs_v563:set(math.max(-arg_145_0.y + 100, math.min(arg_145_0.y - 100, var_145_9)))
		end
	else
		if bs_v575.dragging then
			bs_scope_zoom = nil
		end

		bs_v575.dragging = false
	end

	bs_v575.grab_anim = bs_v575.grab_anim + ((bs_v575.dragging and 1 or 0) - bs_v575.grab_anim) * 0.14

	local var_145_10 = ui.get_mouse_position()
	local var_145_11 = bs_v581(arg_145_0)
	local var_145_12 = var_145_10.x >= var_145_5 - 60 and var_145_10.x <= var_145_5 + 60 and var_145_10.y >= var_145_11 - var_145_8 and var_145_11 >= var_145_10.y

	bs_v575.hover_anim = (bs_v575.hover_anim or 0) + ((var_145_12 and 1 or 0) - (bs_v575.hover_anim or 0)) * 0.12
end

function bs_v760(arg_147_0, arg_147_1)
	if ui.get_alpha() <= 0 then
		return
	end

	local var_147_0 = false

	if bs_tab_dummy then
		local var_147_1, var_147_2 = pcall(function()
			return bs_tab_dummy:get()
		end)

		var_147_0 = var_147_1 and var_147_2 == 2
	end

	if not var_147_0 then
		return
	end

	local var_147_3 = math.max(bs_v575.hover_anim or 0, bs_v575.grab_anim)

	if var_147_3 < 0.005 then
		return
	end

	bs_draw_panel_bg(vector(arg_147_1, bs_v581(arg_147_0) - 7), vector(120, 14), var_147_3)
end

events.render(function()
	local var_149_0 = render.screen_size()
	local var_149_1 = var_149_0.x * 0.5
	local var_149_2 = bs_menu.info.notify

	if not var_149_2 then
		return
	end

	local var_149_3 = ui.get_alpha() > 0
	local var_149_4 = bs_v581(var_149_0)
	local var_149_5 = false
	local var_149_6 = var_149_2.anim_style:get() == "new"
	local var_149_7 = false

	if var_149_3 and bs_tab_dummy then
		local var_149_8, var_149_9 = pcall(function()
			return bs_tab_dummy:get()
		end)

		var_149_7 = var_149_8 and var_149_9 == 2
	end

	bs_v752(var_149_0, var_149_3)

	local function var_149_10(arg_151_0)
		local var_151_0 = 0

		for iter_151_0 = #arg_151_0, 1, -1 do
			local var_151_1 = arg_151_0[iter_151_0]
			local var_151_2
			local var_151_3

			if var_149_6 then
				var_151_2, var_151_3 = bs_v739(var_151_1, var_149_1, var_149_4 - var_151_0, var_149_2)
			else
				var_151_2, var_151_3 = bs_v724(var_151_1, var_149_1, var_149_4 - var_151_0, var_149_2)
			end

			if var_151_2 then
				table.remove(arg_151_0, iter_151_0)
			else
				var_151_0 = var_151_0 + (var_151_3 or 0)
			end
		end
	end

	if var_149_3 and var_149_7 then
		if globals.realtime >= bs_v651 then
			bs_v692()

			bs_v651 = globals.realtime + bs_v659
		end

		if #bs_v620 > 0 then
			var_149_10(bs_v620)
		end
	else
		if #bs_v620 > 0 then
			bs_v620 = {}
			bs_v651 = globals.realtime + 0.5
		end

		if #bs_v496 == 0 then
			bs_v760(var_149_0, var_149_1)

			return
		end

		var_149_10(bs_v496)
	end

	bs_v760(var_149_0, var_149_1)
end)

bs_get_builder = nil
bs_v500 = nil
bs_get_defensive = nil
bs_v509 = nil
bs_v514 = {}
bs_v518 = "bluesense_db"
bs_v523 = db[bs_v518] or {}
bs_v523.default = nil
bs_v528 = "\x8A\xD3\xF7\x1Ee©4\xEBW\x92\r\xBEA|&\x99\x84?p\xC5\x18\xA3^\xF1j\xD5H\x83.\xB9\x14"
bs_v533 = "♡⋆⋆························⋆⋆♡"
bs_v536 = {}

function bs_v540()
	db[bs_v518] = bs_v523
end

bs_v547 = "l29W5AU6JX1CEVIjmNFZM4xv+twdQsHLBrYG3S7h/zkPpbyoaneKqcDR)Tigf0u8"

-- #############################################################################
-- #  [SEC-05] CONFIG SAVE / LOAD (serialize / deserialize)
-- #############################################################################
function bs_encode_config(arg_153_0)
	local var_153_0 = json.stringify(arg_153_0)

	return (var_153_0:gsub(".", function(arg_154_0)
		local var_154_0 = ""
		local var_154_1 = arg_154_0:byte()

		for iter_154_0 = 8, 1, -1 do
			var_154_0 = var_154_0 .. (var_154_1 % 2^iter_154_0 - var_154_1 % 2^(iter_154_0 - 1) > 0 and "1" or "0")
		end

		return var_154_0
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(arg_155_0)
		if #arg_155_0 < 6 then
			return ""
		end

		local var_155_0 = 0

		for iter_155_0 = 1, 6 do
			var_155_0 = var_155_0 + (arg_155_0:sub(iter_155_0, iter_155_0) == "1" and 2^(6 - iter_155_0) or 0)
		end

		return bs_v547:sub(var_155_0 + 1, var_155_0 + 1)
	end) .. ({
		"",
		"==",
		"="
	})[#var_153_0 % 3 + 1]
end

function bs_decode_config(arg_156_0)
	local var_156_0, var_156_1 = pcall(function()
		local var_157_0 = string.gsub(arg_156_0, "[^" .. bs_v547 .. "=]", ""):gsub(".", function(arg_158_0)
			if arg_158_0 == "=" then
				return ""
			end

			local var_158_0 = ""
			local var_158_1 = bs_v547:find(arg_158_0, 1, true) - 1

			for iter_158_0 = 6, 1, -1 do
				var_158_0 = var_158_0 .. (var_158_1 % 2^iter_158_0 - var_158_1 % 2^(iter_158_0 - 1) > 0 and "1" or "0")
			end

			return var_158_0
		end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(arg_159_0)
			if #arg_159_0 ~= 8 then
				return ""
			end

			local var_159_0 = 0

			for iter_159_0 = 1, 8 do
				var_159_0 = var_159_0 + (arg_159_0:sub(iter_159_0, iter_159_0) == "1" and 2^(8 - iter_159_0) or 0)
			end

			return string.char(var_159_0)
		end)

		return json.parse(var_157_0)
	end)

	if not var_156_0 then
		bs_logger:error("unable to decrypt config")

		return
	end

	return var_156_1
end

function bs_v574()
	local var_160_0 = {}

	for iter_160_0, iter_160_1 in ipairs(bs_ui_cache) do
		var_160_0[iter_160_1.name .. ":x"] = iter_160_1.game_refs[1]:get()
		var_160_0[iter_160_1.name .. ":y"] = iter_160_1.game_refs[2]:get()
	end

	return var_160_0
end

bs_v580 = {}

function bs_v588(arg_161_0, arg_161_1, arg_161_2)
	table.insert(bs_v580, {
		key = arg_161_0,
		get = arg_161_1,
		set = arg_161_2
	})
end

function bs_v593()
	local var_162_0 = bs_v574()

	for iter_162_0, iter_162_1 in ipairs(bs_v580) do
		local var_162_1, var_162_2 = pcall(iter_162_1.get)

		if var_162_1 then
			var_162_0[iter_162_1.key] = var_162_2
		end
	end

	for iter_162_2, iter_162_3 in ipairs(bs_reset_cbs) do
		local var_162_3, var_162_4 = pcall(iter_162_3.get)

		if var_162_3 then
			var_162_0[iter_162_3.key] = var_162_4
		end
	end

	return var_162_0
end

function bs_apply_positions(arg_163_0)
	if type(arg_163_0) ~= "table" then
		return
	end

	for iter_163_0, iter_163_1 in ipairs(bs_ui_cache) do
		local var_163_0 = iter_163_1.name .. ":x"
		local var_163_1 = iter_163_1.name .. ":y"

		if arg_163_0[var_163_0] then
			iter_163_1.game_refs[1]:set(arg_163_0[var_163_0])

			iter_163_1.smooth_x = arg_163_0[var_163_0]
		end

		if arg_163_0[var_163_1] then
			iter_163_1.game_refs[2]:set(arg_163_0[var_163_1])

			iter_163_1.smooth_y = arg_163_0[var_163_1]
		end
	end

	for iter_163_2, iter_163_3 in ipairs(bs_v580) do
		if arg_163_0[iter_163_3.key] then
			pcall(iter_163_3.set, arg_163_0[iter_163_3.key])
		end
	end

	for iter_163_4, iter_163_5 in ipairs(bs_reset_cbs) do
		if arg_163_0[iter_163_5.key] then
			pcall(iter_163_5.set, arg_163_0[iter_163_5.key])
		end
	end
end

bs_v514.register_position_extra = bs_v588
bs_v514.save_positions_full = bs_v593
bs_v514.load_positions_full = bs_apply_positions
bs_v609 = "default"
bs_v619 = "HeXrsvN/dRJYIYX7+xnKtxMYC9XYsxSptU4eJG/YFU4+QhsDFSSXw62ts7EaQYpRs5nN4vXeMMmqZUNtF7SANYSrmKS+Z6t5m4SqMK2rsc42FRNDN4SXMDXhF7r+Q7mRZ3n3H55zF3QoM3V6d621wAretWsIZUN)MRS1Ne0nmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE6tU+43PHABRs3NMdRV4MKsJN3zzQKt++RNU+43PHABRsSJeCebD4SVDMStZtWS1wMz6V4SWI4re1KsqZA5RV5bqs3TEQc4Z+hNDFSSXNqzTNZSrxFb)xWsDM3TSsRrKw6NDFSSXx4rttAXICqzt+43PHUTatAXKZAAFZhXK4MctFxrItvV)Zv21VqATQc4ZZ9b/xUVK4ZmRtAX+NRNUF7SKVSrGs5trxFpREWVJVW2M1RtNxMS/Z74KH5caFGs+dRmDMqnJH5AFs3NIMDN4m4N1Ne0rmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMs3NGdRN4Z4SXx4rCQc42Qvs)N4SWI4rtt5NI46tFMRXK+KlKs6ryQ3BqEUMPHAmKt5NGZUN)mFS1Ne0GmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSX+Q7mRZ703VW2YsRBzxMS6FhSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNys3NxdRV)46A1NefzmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAN3zzN4zpHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34yNZS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMb1xMS61RSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAFqz6CqbWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFc+TF7SXNYSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACZ4SXNqXTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNMN1Ne0SmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxtMzzN4zAHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM3MzF3Qo+qV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CFMt1w4+T1xAWI4rtt5NI46tFMRXK+K2Yt5NIMqz6CcSRVcVnQcMqtMzt+43PN6XosqNVxMStxWVqH6NeQRryQMzt+43PN6XosqNVdhtCV4SXNqzTNZSrxFb5Q70RN5cys3b1xMS6VxAWNDnaFGsxCDN5+SVAVUtCF3QotMV6d621Vc+ot5NYMqMqthA1Ne0SmqspQ5/R4Y03NUXZNZN7+qz6CD4WNDnaFGsxCDN5+SVAVUt5F3QotMV6d621Vc+ot5NYMRt5sU43N6AtFMQcN5V6d621Vc+ot5NYMRt5+cVK4vXosWS1wMz/x6X3VRVZFSSrxFb5Q70RNWNEMMNyHhN4VU41Ne0y4S3z+METx5sR4Z2msWmaFDN4MKVqsSrCF3QotMV6d621Vc+ot5NYMRtFZ701Ne0y4S3z+METxWVKH5Aas3NIHSAFZ74RHArGQc4ZdDNtF7S1VqAaQcMqtxmRmvAqN3zaFGsI+eb)d3n34ZmRQq5adRmR1cSXxvA5NZ3z+METxWVKH5AasSX+QhV4Z4SXNqzTNZSrxvmDV6X3mZ2S1RtIMRt5FSSXNDcTNZSrxvmDV6X3mZ2SsRrKCRV2EU0qVebtFMQP+MV6d621VRNesqmqZUN4MDXRs7ctFMQP+MV6d621VRNSs6BqFRV4mvSqmZ2rs6BqM5z6CcS3N6mRFSSrxxN4VWsKmZ2asRrGHhETF7Sxx3XTNZSrxxN)mFS1Ne0rmqspQ5/R+Rz3xMzzNZ3z+METxUX3N5TisWsZMcAtF7S1VqTiMMN2xxN4VWV1xxAtt6BaERs)s6zqsSrE1cJqFRV4EUXDMStasRrIMcA/N4SXNqzTNZSrxxN)EWVRH6Nis6t+ZUN)EWVqN3zzF7BqHvs)sU0NVRAtmKS++7N5ZhzqVcVZM4EadRmRs5bqs7ctFMspHMMT+4S3HWlKsRrqHhNDx5nNVGNaMMmqZ9bUF7SWxYbrmqspQ5/R+D0q44ERsRBqtvtFE7V3VStZs3N1xMS61DAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDMSreQc4VxMS6mhSAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtyF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nAxMzzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCN4SXNDnTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7QMz6CDAWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtE43t1wMMT1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFebtFMspHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvt54SV3w5TZM4S1w4twd6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADMStrMZQqQhmTF7SxNDnTNZSrx45RmvSq4Z2Ys3NxCDN5+SV1NR/R1RryFRNU+4SNVqATsAMa+hsDHSV1NR/R1RryFRNU+4SNVcV/sKtIZUN4MDXRs7ctFMsV45V6d621wAtmsRtIQvNDx5nq4ZN/F3QoQ4tU1xAWI4rM1RtKZ9pRmMbqN3zzFGs2QM/DZhXNVRVZQKS1Q5z/MRXK+K2as6rqQMz6CDXANK4TNZSrxMr)m4XDMSris5NeQMz6CqbAIFSrZ5trxFb)MD4144tStAJqNRs4MRSqtMzzFU4+Z6t5m4SqMK2rsc42FRmqE6S1Ne0ymqspQ5zZE5aPHABRsSJeCebD4SVNtMzzHAXax45RmvSqmZ2Y1Rt9xMS6MvSAIxAtMZs2HvN2EUXRH9StF4SnFqV6EG2WVh2tMZs2HvN2EUJPs3XtF4SndStS1xAWI4rS1RrMERt5+Rz3xMzzN4/PHMMDQv2Jt4rS1RrMERt5+RXJIMzzN4zpHMMT+4SNVqATs55a+hs)14SXxvAFmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtGQqETx6JPVRNEtWQaQvs)sAN1NRznMxBqMqETx6JPVRNEM44eQSA5V5nNNWNaF3QoxM4UFh21VqAtsAEatvND4SVKmZ2nsRrGMcAtF7SxIFSrmKS+QYpRs5nKVSris5NKMcAtF7S1VcroQc49xMETx6X34xToQDEaFRV4mvAqN3zzQKt++RNU+43PHANnsKmax4A/V6AqH6NoMZsxMqz6HGQPHUTCs5trxFpREWVJVW2M1RtNxMS/Z74KH5caFGs+dRmDMqnJH5AFs3NIMDN4m4N1Ne0rmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMs3NGdRN4Z4SXx4rCQc42Qvs)N4SWI4rtt5NI46tFMRXK+KlKs6ryQ3BqEUMPHAmKt5NGZUN)mFS1NefzmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSX+Q7mRZ703VW2YsRBzxMS6FhSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNys3NxdRV)46A1Ne0FmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAN3zzNxMz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFK4rF3Qo+MV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CN4S1w4tt1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbAxMS6VMNWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFc+TF7SxxFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACZ4SXNqzTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNMN1Ne0GmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxtMzzN4/cHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM3MzF3QodStt1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMpKxMS6MvSAIxAt1KQaEqBqEAmPshVEt6BaERNUF7S1VRziQKtIMcAtFh21Vc+ot5NYMqz6CcSq4ZmR1R+qQ6ETFh21Vc+ot5NYMqMqt7T1Ne0yNZ3z+METx5sR4Z2msAz2Z54tF7SAxFSrmKS+NRs4EA2qx3AENx41wM4t1xAWI4r6scMaM6NwmMnxIMzzN43z+METx5sR4Z2msAz2ZAtUF7SAxFSrmKS+NRs4EA2qx3AE4SS1wM4t1xAWI4r6scMaM6mqEWsNVK2YF3QodStU1xAWI4r6scMaM6mqEUXqs3)ot5NbxMStxUMPHAN/s5t1Q5/R4Y03NUXZsSXxQ6s)ZSVNxMzzN4zVHMMT+43PN6XosqmqZAA5dhzq4ZNSMx41w4+T1xAWI4r6scMaM6mqE6A3tMzzNMs1HMMT+4SqVGNet55aERsD4hANVcVtQRtIH7N514SXx4rS1RrMEDN5Q4SWI4BKQRr2Q6t5dSVqw5TEt5NqVqz6CDXANYSrmKS+ERV)mv2DMSreQc4VxMS6FhSAIxAtsW+qQ7N2EUMPs3TZs3N1xMS6dvSAIxAtsW+qQ7N2EU4RH6EoQq5adRmR1cSXNqcTNZSrxvmRm42qVW2asRrGHhETF7SxNDnTNZSrxvN/xAVqsStn1RrMERtFESVqH62tF4S+dRmR1cSWI4ras6rqQvt5dhz3HAVnF3Qo+q3T1xAWI4rY1Rt9xMS6FhAWNDnaFGsGH7NtF7SAIFSrmKS++7N5ZhzqVcVZM4S1wM/REWsqwAtZQKS1Q5/R+D0q44ERsRBqtvt547VNM3TotWmaFDN4MKVqsSrCF3QoN5V6d621VDVosA4ZVRs)VU4DNUVosA4VxMStxAXqHAV/sKtIMRmTFh21VDVosA4ZVRs)VU4DNWlRsUrxMRETF7SANYSrmKS++7N5ZhzqVcVZM4Ea+vV)d3bqVW2eF3Qo+St6d6SAIxAtt6BaERs)s6zqsSrEMZ+qQAA5V5aPxMzz43spHMMT+4S3HWlKsRrqHhNDx5nNVGNaMMmqZA5RmvAqN3zzFZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCV4SXxvAymqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54tF7SAxFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3bAxMStQxTWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtE4GS1wM4S1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFqctF4Snd3V6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nxxMzzmczbHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvt54SV3w5TZM4S1w4twd6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADMStrMZQqQhmTF7SxNDnTNZSrx45RmvSq4Z2Ys3NxCDN5+SV1NR/R1RryFRNU+4SNVqATsAMa+hsDHSV1NR/R1RryFRNU+4SNVcV/sKtIZUN4MDXRs7ctFMsV45V6d621wAtmsRtIQvNDx5nq4ZN/F3Qo+qV6d621wAVeQDEaxFbD4SV1Ne0t1RtbmhV4mx4qNWNnFSSrxMr)m4XDNUTZsUrbxMStQx4xxFSrmKS+49bDQqnNVcV/sKtbxMS6N4XWNKJamKS+Nc5REUEPN6XitWsNxMS/QASD+K2e1KsqZAA4QhXNNWNEtAS1wMMT1xAWI4rEs3N2xvNZEUAR4MACs6tAxMSZ+7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJas3trxFb)xWsDNANoQc4ZVqrUF7SKVSrGs5trxFb)xWsDMGJo1RtxMRtF4SV3IMzzF3QcxMETx6JPVRNEMZQqFRNDZ3nK44VYs6t1xMS6NvSAIxAt1Rr+VRtFZ74RH6V/s6t1xMStxUXRsStCFSSrxFb)dh23MhVEM4XIQhV4Z4SXw5TSQRrVQ5/RmvSK44VE1Dr++RV4VWs3MSr6s5t1wvmRmv2NN5caFGs+dRmDMqnJH5AFF3siQ4A/VAVWI4rtt5NI46tFMRXK+KlKs6ryQ3rUF7SAIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Yt5NIMqz6CcSNM3TeQc4ZNqzt+43PVKlKFWma49bDQqnq4ZNa1RtZZA5RmvSq4Z2Ys3NGQ3BTF7SxxFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2S1RrMEDN5+qn3HAVTF3QotMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW26tAJqHvETF7SAtFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACV4SXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNxTAIMzz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFqztFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34CF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2C4GS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbVxMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAN5z6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFctSF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACmSSXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFN4N1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5+D0q4MctF4S+FRV4mvARH54tmKS+NRs4EA2qN3zzFGsIMRmRmxV3V7ctmKS+NRs4EA2qx3AENMt1wM4t1xAWI4r6scMaM6NwmMnAxMzzN43z+METx5sR4Z2msAz2Z54SF7SAxFSrmKS+NRs4EA2qx3AE4GS1wM4wd6SAIxAt1qNedRs5ZxTDFqctFMs1HMMT+43PN6XosqNVdhtC1cSXNqzTNZSrxFb5Q70RNWNEsUr+dDNUF7SAxYbTNZSrxFb5Q70RNWNEt6BqQvs4EWV1Ne0tMZs2HvN5Z4SWI4r6scMaM6mqE5b344EKs6t1xMS6VMNWNDnaFGsxCDN5+SVDMStasRrIMcA/N4SXNqzTNZSrxFb5Q70RNWNEQc47xMS6VMNWNDnaFGsI+eb)d3nq44VCQKt+HYb/V6ARHW2TF3QoxFb)dhAqsSrT1RtIMqzt+4SqVGNet55aQ6N)s6ADNWlRsAS1wMVw1DAWNDnaFGsI+eb)d3nNVqAns5t1wM4t1xAWI4BKQRr2Q6tFx6XK4ZNE1cS1w4+T1xAWI4BKQRr2Q6tFx6zqN6Xns3maVRNtF7SxNDnTNZSrxvmRm42qVW2asRrGHhETF7SxNDnTNZSrxvN/xAVqsStn1RrMERtFESVqH62tF4S+dRmR1cSWI4ras6rqQvt5dhz3HAVnF3QoN5MT1xAWI4rY1Rt9xMS6d6SAIxAtt6rZHMz6CDAWNDnaFGsGdRN4MKsRHWNSF3QoxvN4MqpPHAras6rbxMETxUX3N5TisWsZMcAZE5sKsStnt5NGZAA5dhzq4ZNSMx41w4tU1xAWI4rYt5NIHhmRMcVNMK2Yt5NIMqz6Cc3PMGNCQcMa+3zt+4S3HWlKsRrqHhNDx5n3N6mRMMmqQMz6CDAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDNW4tF4SnN5MT1xAWI4rYt5NIHhmRMcVNMK2rQRryFRmqEAS1Ne05NZ3z+METxUX3N5TisWsZMcAZEUAKHUTCsWmatFbDZSV1NefzmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54UF7SxIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3b1xMS6d6SAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtCF3QoM3V6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nxIMzzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCZ4SXxvAymqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZAttF7SAIFSrmKS++7N5ZhzqVcVZM4EaMhN)MDrRV3TE1qmqHvV4VU41Ne0GNZ3z+METxUX3N5TisWsZMcAZEAXqHAV/sKtIZAAFE74qH55KF3QoN5MT1xAWI4rS1RrMEDN5+qaPN6XosqNVxM3Rs6X3VStZmKS+tFb)4WV3NUViFWsVxMS/Z74KH5caF7r+HhN5QhADNUTit6rZQMz6CqNAIFSrmKS+FRs5MRAK4ZNSs3NIMRNSF7Sx4qcTNZSrxMr)m4XDNAreMMNVxMStx6XKIZXn1Rt+w6NDd4SWI4rM1RtKZUN4VWsKIMzzNZ3z+METxAmPshVEMZsZw6QDd4SXNDnTNZtnQ5/Rs6XRNWNa1RrNxMS/QASD+K2e1KsqZAA4QhXNNWNEtAS1wM4U1xAWI4rEs3N2xvNZEUAR4MACs6tAxMSZ+7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJas3trxFb)xWsDNANoQc4ZVqrUF7SKVSrGs5trxFb)xWsDMGJo1RtxMRtF4SV3IMzzF3QcxMETx6JPVRNEMZQqFRNDZ3nK44VYs6t1xMS6NvSAIxAt1Rr+VRtFZ74RH6V/s6t1xMStxUXRsStCFSSrxFb)dh23MhVEM4XIQhV4Z4SXw5TSQRrVQ5/RmvSK44VE1Dr++RV4VWs3MSr6s5t1wvmRmv2NN5caFGs+dRmDMqnJH5AFF3siQ4A/VAVWI4rtt5NI46tFMRXK+KlKs6ryQ3rUF7SAIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Yt5NIMqz6CcSNM3TeQc4ZNqzt+43PVKlKFWma49bDQqnq4ZNa1RtZZA5RmvSq4Z2Ys3NGQ3BTF7SxxFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2S1RrMEDN5+qn3HAVTF3QotMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW26tAJqHvETF7SAtFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACV4SXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNxTAIMzz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFqztFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34CF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2C4GS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbVxMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAN5z6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFctSF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACmSSXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFN4N1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5+D0q4MctF4S+wRsDZhAqs3ztmKS+NRs4EA2qN3zzFGsIMRmRmxV3V7ctmKS+NRs4EA2qx3AENMt1w4+T1xAWI4r6scMaM6NwmMnAxMzz4G3z+METx5sR4Z2msAz2Z54SF7SxIFSrmKS+NRs4EA2qx3AE4GS1w4+T1xAWI4r6scMaM6NwmMnxN3zz4G3z+METx5sR4Z2msAz2ZAttF7SxIFSrmKS+NRs4EA2qVWlRMZQa+3z6CeSWNDnaFGsxCDN5+SVDNUVZQc4edRmTF7S1wAretWsKMqzt+43PN6XosqmqZAA5dhzq4ZNSF3QodStt1xAWI4r6scMaM6mqE5b344EKs6t+Fqz6CD4WNDnaFGsxCDN5+SVDM3ToF3QodStt1xAWI4BKQRr2Q6t5ZhzNM3TSsRr++RV4MD03xMzzFGs2Q6V4VU43VqAns5t1Q5/RZ7EPHUTEtAMqVRV2EU0qVebtF4SnN5MT1xAWI4BKQRr2Q6tFx6XK4MctFMs1HMMT+4SqVGNet55atFbDZSVDN5ztFMsbHMMT+4SqVGNet55atvs)Qe0KmZ2osWQPxMS61DAWNDnaFGsqQhs5V5n344VYsRtbxMS61DAWNDnaFGsqtvN)V5bK4MATs55a+vN)VA21Ne0tM4MqMRsSEGQPHUXZFSSrxxN4VWsKmZ2asRrGHhETF7SxNDnTNZSrxxN)mFS1Ne05NZ3z+METxUXRH9StF4SnN5MT1xAWI4rYt5NIHhmRMcVNxMzzFGsIHSA5m4S34ZmKFSSrxxN)EWVRH6Nis6t+Z9bFV5bK4Z2YsSXxQ6s)ZSVNw54tFMs1HMMT+4S3HWlKsRrqHhNDx5n3HWlKs5t1wMz/V6SRH6NoMZsnxMETxUX3N5TisWsZMcAZEU0qVRNCs6tbxMS6d6SAIxAtt6BaERs)s6zqsSrEMZ+qQAA5V5aPN3zzmc/P+MV6d621VDVosA4ZVRs)VU4DMGXGtWtxMRt5FSSXNebrmqspQ5/R+D0q44ERsRBqtvtFE7V3VStZsSX+QhV4Z4SXNqXTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7d3z6CDAWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtEN4S1wMMT1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFq4tFMspHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGthA1Ne0rmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZAtUF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3pPxMS6d6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADNAtZtUrIMcAtF7Sxx7nTNZSrxxN)EWVRH6Nis6t+Z6V5V6zqN6XnsSXx+45RV6XqIMzz43spHMMT+4SNVqATsAMa+ht54Y03NUXZF3siVeb)d3bqN7AtMZs2HvN4EUXRshzZF3siVeb)d3bqN7AtMZsZw6QDZ3n344VYsRtbxMS61DAWNDnaF7rxM6sDZhAqsSrEsAMqw5z6CRAxNYSrmKS+49bDQqaPVqACs5t1wM/RmvA1V3TeMZsKMRETFh21wAVeQDEaQ6N)s6A1Ne0YN4/KHMMT+4SJH5AFsSX+HhN5QhA1Ne0CNxMz+MnU+4S34ZN/sRtbmYb)V4SXw62ts7EaQYpRs5nN4vXeMMmqZUNtF7SAIFSrmKS+Z6t5m4SqMK2rsc42FRNDN4SXMDXhF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE6tU+43PHABRs3NMdRV4MKsJN3zzQKt++RNU+43PHABRsSJeCebD4SVDMStZtWS1wMz6V4SWI4re1KsqZA5RV5bqs3TEQc4Z+hNDFSSXNq4TNZSrxFb)xWsDM3TSsRrKw6NDFSSXx4rYsRtxFqzt+43PHUTatAXKZAAFZhXK4MctFxrItvV)Zv21VqATQc4ZZ9b/xUVK4ZmRtAX+NRNUF7SqVqAaMMNVQ5/RxU0qVSVEF6r2M3z6HhANwWNZmKS+xxN5ZSNDMSVeQDEaERN)dhXJN3zzNZ3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWma+7N5ZSV1Ne0tM4XIQhV4Mqs1xxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNVqATsAMa+ht5+RXJIMzz4S3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmatFb)4WV3NUVEt6rZHMz6CD4WNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaNDNFV6SKIMzzNxMz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFK4tFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34yNZS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMb1xMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAFqz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFc+TF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACZ4SXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNMN1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxtMzz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFqXtFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34MF3QoQMV6d621VcrosWtZZ5r)m4XDNUVosA4VxMStxUbRs3Tns6t1xMETx5sR4Z2ms5t1wM/RZSVqVqAGtWtbxMETx5sR4Z2msAz2Z54UF7SAxFSrmKS+NRs4EA2qx3AEN4S1wM4t1xAWI4r6scMaM6NwmMnAtMzzN43z+METx5sR4Z2msAz2ZA+TF7SAxFSrmKS+NRs4EA2qx3AE43t1wM4t1xAWI4r6scMaM6NwmMnxxMzzN43z+METx5sR4Z2msWmaVc5REUX1Ne0y4S3z+METx5sR4Z2msWma+hNDZY03NUctF4S+tFb)4UrqN3zaFGsxCDN5+SVDMStasRrIMcAtF7SAxYbTNZSrxFb5Q70RNWNEMMNyHhN4VU4NtMzzN43z+METx5sR4Z2msWmaQxNSF7SAxYbTNZSrxvmDV6X3mZlKsRtxQ45RMcSKs3Tit5mzxMStx6X3V3TZMZsMQhV4Z4SWI4BKQRr2Q6t5dSVqw5TEt5NqVqz6CDXxNDnTNZSrxvmDV6X3mZ2S1RtIMqz6CD4WNDnaFGsI+eb)d3nNVqAnsWmaxMz6CRAWNDnaFGsI+eb)d3nNVcV/sKtIZUN5sWs1Ne05NZ3z+METxWQPHUXZs3NyH7N)MRA1Ne05NZ3z+METxWsNVKNZM4XIQ7mRZ3nN4ZNZsD41wMz/ESVqH629sWs2M6NUFh21VDTZsUrIZUN4MDXRs7ctFMQP+MV6d621VDVeFWS1wMMT1xAWI4rYsRBzxMS6d6SAIxAtt6BaERs)s6zqs3ztF4S+ERsD4hJPVDTZsWS1Q5/R+D0q44ERsRBqtvt547VNM3TotWmaFDN4MKVqsSrCF3QotMV6d621VDVosA4ZVRs)VU4DNUVosA4VxMStxUV3VcERtAX++3zt+4S3HWlKsRrqHhNDx5n3N6mRMMmqQMz6CDAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDNW4tF4SnN5MT1xAWI4rYt5NIHhmRMcVNMK2rQRryFRmqEAS1Ne05NZ3z+METxUX3N5TisWsZMcAZEUAKHUTCsWmatFbDZSV1NefzmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54UF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3b1xMS6d6SAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtCF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nxIMzzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCZ4SXNDnTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7N5z6CDAWNDnaFGsGdRN4MKsRHWNSsSXKMRs)Qe0KmZ26s6rMQvNDFSSXNqcrmqspQ5/R+D0q44ERsRBqtvtFQcVRH6EoQq5aFc5DxAEPHUctFMQP+MV6d621wAretWsIdDmqE5sR4Z2ms5t1wvEDxUVqN7AtMZs2HvN4EUXRshzZF3siVeb)d3bqN7AtMZsZw6QDZ3n344VYsRtbxMS61DAWNDnaF7rxM6sDZhAqsSrEsAMqw5z6CRAxNYSrmKS+49bDQqaPVqACs5t1wM/Rd7fPN5AaFGtqHhNDM4SWI4rM1RtKZUN4VWsKIMzzmc/c1MMT1xAWI4rM1RtKZA5RMDrRV7ctF4Snd3Svd6SAVhAaF7r++DmR46z3VcAtFxraxvtGE6JPVRNEM44eQSA5V5n3xMzzNxMz+METx5nDN5AtsAEa+vs4mMbqs34tF4VYtqz/x6X3VqTEt6r21Mz6CcXWNDnaF7r+Q7mRZ3n3HAVTF3Qo+34S1xAEN7ThF7r+Q7mRZ3n3H55zF3Qod34t1xAWI4rS1RrMERt5+Rz3xMzzmc/KHMMDQv2Jt4rS1RrMERt5+RXJIMzzN4zpHMMT+4SNVqATs55a+hs)14SXNq4TNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZWNnQ5/Rm4SqMK2TtAXIHhN/EcSXw5TSQRrVQ5/Rm4SqMK2rsc42FRmqE5bqHUAtF4S1d3zt+43PHABRsSX+McA5V6ADM3Tit6BqtMz6CD4WNDnaFGs2xvNZE6ANVcV/s5mqtMz6Cc3PVK2nsKS1Q5/Rmv234Z2FsSXxQFbDZSV1NRznMxBqMqETx6X3w5Tis3N+tvVDZSVqVK2S1qNVxM3Rs6X3VStZmKS+xxN5ZSNDMSVeQD41wvEDxUVqN7At1KQaEqBqEAmPshVEsAMqQ9bDEcSXNDnTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEt6BaERNUF7S1wAtn1RtIHYbSFh21VcrosWtZZ5r)m4XDN5TZtA4246tFx6X3VqTotWma+YbDmSSXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMZs2HvN4EUXDNUVitAS1wM4U1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AE1qma+DN/d4SXNq4TNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNxT1Ne05mqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAx7ntFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34SF3Qod3MT1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbAxMS6mhSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAQMz6CDTAxFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACZ4SXNebTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNMN1Ne0SmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxtMzzN4zNHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM3MzF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CFMt1w4+T1xAWI4rtt5NI46tFMRXK+K2Yt5NIMqz6CcSRVcVnQcMqtMzt+43PN6XosqNVxMStxWVqH6NeQRryQMzt+43PN6XosqNVdhtCV4SXNK4FmqspQ5/R4Y03NUXZNZN7tMz6CDTAIFSrmKS+NRs4EA2qx3AENx41wM4t1xAWI4r6scMaM6NwmMnxIMzzN43z+METx5sR4Z2msAz2ZAtUF7SAxFSrmKS+NRs4EA2qx3AE4SS1wM4wdvSAIxAt1qNedRs5V5nqwArot5t1w4tt1xAWI4r6scMaM6mqEUXqs3)ot5NbxMStxUMPHAN/s5t1Q5/R4Y03NUXZsSXxQ6s)ZSVNxMzzN4/PHMMT+43PN6XosqmqZAA5dhzq4ZNSMx41w4tU1xAWI4r6scMaM6mqE6A3tMzzN4/PHMMT+4SqVGNet55aERsD4hANVcVtQRtIH7N514SXx4retWtIMc5R46XK4MctmKS+ERV)mv2DNUTZsUrIZUN5sWs1Ne0Y4S3z+METxWVKH5AasSX+QhV4Z4SXNDcTNZSrxvmDV6X3mZ2S1RtIMRt5FSSXNDcTNZSrxvmDV6X3mZ2SsRrKCRV2EU0qVebtFMQctMV6d621VRNesqmqZUN4MDXRs7ctFMQP+MV6d621VRNSs6BqFRV4mvSqmZ2rs6BqM5z6CcS3N6mRFSSrxxN4VWsKmZ2asRrGHhETF7SxxGVTNZSrxxN)mFS1Ne0nmqspQ5/R+Rz3xMzzmcz1HMMT+4S3HWlKsRrqHhNDFSSXx4BKsRtxQYpRdSVqIMzaFGsGdRN4MKsRHWNSs3Nx+cAFZ703VW2CtA4ZERNDx5b1Ne0nmqspQ5/R+D0q44ERsRBqtvt5+D0q4MctF4S+NRVD4hA3N6AtmKS++7N5ZhzqVcVZM4EadRmRs5bqs7ctF4SnFqV6d621VDVosA4ZVRs)VU4DMGXGtWtxMRt5V4SXxvA5NZ3z+METxUX3N5TisWsZMcAZEUAKHUTCsWmaxMz6CqNAIFSrmKS++7N5ZhzqVcVZM4Ea+vV)d3bqVW2S1RtIMqz6CeSWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtENMt1wMSU1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFqztF4Snd33T1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFq4tFMspHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGthA1Ne0MmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZAtUF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3pPxMS6d6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADNAtZtUrIMcAtF7Sxx7nTNZSrxxN)EWVRH6Nis6t+Z6V5V6zqN6XnsSXx+45RV6XqIMzz43spHMMT+4SNVqATsAMa+ht54Y03NUXZF3siQ4A/VAVWI4rS1RrMEDN5+RzJVqctFxrItvV)Zv21wAris5NeQvt5dhz3HAVnF3Qo+q3T1xAWI4rCsqNZQvV4VU4DN5TZsU41w4tU1xAWI4rM1RtKZ9pRmMbqN3zzFGs2QM/DZhXNVRVZQKS1Q5z/MRXK+K2as6rqQMz6CDXANDcTNZSrxMr)m4XDMSris5NeQMz6CqbAtFSrZ5trx4A5d70KNAVTsU41wMrSx5nDN5AtsAEa+vs4mMbqVW2TF3Qo+MV6d621MK2E1Rr+VRtFEYfPsStZMx41wvrFQASNVqATs55a+YbDmSSXNcATNZSrx45RmvSqmZ2YsRBzxMStQvAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJas3trxFb)xWsDNANoQc4ZVqrUF7SKVSrGs5trxFb)xWsDMGJo1RtxMRtF4SV3IMzzF3QcxMETx6JPVRNEMZQqFRNDZ3nK44VYs6t1xMS6VvSAIxAt1Rr+VRtFZ74RH6V/s6t1xMStxAS3M3)oFSSrxFb)dh23MhVEM4XIQhV4Z4SXw5TSQRrVQ5/RmvSK44VE1Dr++RV4VWs3MSr6s5t1wvmRmv2NN5caFGs+dRmDMqnJH5AFF3siQ4A/VAVWI4rtt5NI46tFMRXK+KlKs6ryQ3rUF7SAIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Yt5NIMqz6CcSNM3TeQc4ZNqzt+43PVKlKFWma49bDQqnq4ZNa1RtZZA5RmvSq4Z2Ys3NGQ3BTF7SAx34TNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMZs2HvN4EUXDNUVitAS1wM4t1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AE1qma+DN/d4SXNcATNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNxT1Ne0GmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAx7ntFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34SF3Qod34t1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbAxMS6ZvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAQMz6CqbWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFctUF7SAx34TNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNMN1Ne0ymqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxtMzz47Mz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFqXtFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34MF3QoQMV6d621VcrosWtZZ5r)m4XDNUVosA4VxMStxUbRs3Tns6t1xMETx5sR4Z2ms5t1wM/RZSVqVqAGtWtbxMETx5sR4Z2msAz2Z54UF7SAxFSrmKS+NRs4EA2qx3AEN4S1wM4t1xAWI4r6scMaM6NwmMnAtMzzN43z+METx5sR4Z2msAz2ZA+TF7SAxFSrmKS+NRs4EA2qx3AE43t1wM4wd6SAIxAt1qNedRs5ZxTDFebtFMs1HMMT+43PN6XosqmqZ6N/xU03N3zzN4/PHMMT+43PN6XosqmqZUN)V6AR4ZlKF3Qox45RmvSqN5ctmKS+NRs4EA2qVW2CtA4ZERNDFSSXNK45mqspQ5/R4Y03NUXZsSXxQ6s)ZSVNw54tFMs1HMMT+43PN6XosqmqZ6V4tSSXNK45mqspQ5/RZ7EPHUTEsA4ZFREDx6/PwWNnsRBaHMz6Cc3PHUTns6t+HFbDZSV1xxAtsW+qQ7N2E62qH6Nns3maVRNtF7SWxYbrmqspQ5/RZ7EPHUTEMZs2QvNUF7SAxFSrmKS+ERV)mv2DMSreQcMqZ9btF7SxIFSrmKS+ERV)mv2DMSris5NeQvt5EWsqxMzz43spHMMT+4SqVqAmsWmaQ6s)+RzKIMzz43spHMMT+4SqwArZs6txQFb)4WVDMGXZs6raxMStxU0qVebtmKS+Q6N)s6ADNUTit6rZQMz6CDVXNYSrmKS++YbDmSSXNcATNZSrxxN)MRS1Ne0Y4S3z+METxUX3N5TisWsZMcAtF7S1VKlRsUrxMRETFh21VDVosA4ZVRs)VU4DNAtGM4XIdDmqE5b344EKs6t+Fqz6CDVWNDnaFGsGdRN4MKsRHWNSs3NGdRN4Z4SXx4rGtWsZVDNFxUX1xxAtt6BaERs)s6zqsSrEt5NqVcA5V6A1Ne0YNM+z+METxUX3N5TisWsZMcAZEUAKHUTCsWmaQ3z6CDXxNDnTNZSrxxN)EWVRH6Nis6t+ZA5DV62NNWNE1cS1w4t6d6SAIxAtt6BaERs)s6zqsSrEMZ+qQAA5V5nNVqAns5t1wM3T1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFK4tF4Snd34t1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFqztFMspHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt3b1Ne0rmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZA+TF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3bVxMS6d6SAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+Dt5F3Qo+MV6d621VDVosA4ZVRs)VU4DMhVZsRrKCRV2E5sqHANns6t1xMS6ZxAWNDnaFGsGdRN4MKsRHWNSsSXKMRs)Qe0KmZ2CMZt+Meb)d4SXNebrmqspQ5z/x6X3VqTotWmaNRs4EA2qN3zzsWs2QAA5Zv21wAretWsIdDN)MDSqN3zzsWs2QAA5Zv21wAris5NeQvt5dhz3HAVnF3Qo+q3T1xAWI4rCsqNZQvV4VU4DN5TZsU41wM4wd6SAIxAtF6r2Mht5x6XNN5ctF4S+QhETEh5PsSr/s6tbxMETxAmPshVEtAMqVRETF7SWx3MzmqspQ5z/MRXK+K2SsRrKCRETF7Sx4qzTNZtnQ5z/4hSqH5AmsRrMw5z6H7s1MK2E1Rr+VRtFEYfPsStZs3mzxMS6d6SAIxAts7EaQYpRs5nN4vXeMMmqFqz6H7NJt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZWNnQ5/Rm4SqMK2TtAXIHhN/EcSXw5TSQRrVQ5/Rm4SqMK2rsc42FRmqE5bqHUAtF4S1d3zt+43PHABRsSX+McA5V6ADM3Tit6BqtMz6CqbWNDnaFGs2xvNZE6ANVcV/s5mqtMz6CcS3HAVCMx41Q5/Rmv234Z2FsSXxQFbDZSV1NRznMxBqMqETx6X3w5Tis3N+tvVDZSVqVK2S1qNVxM3Rs6X3VStZmKS+xxN5ZSNDMSVeQD41wvEDxUVqN7At1KQaEqBqEAmPshVEsAMqQ9bDEcSXNDnTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEt6BaERNUF7S1wAtn1RtIHYbSFh21VcrosWtZZ5r)m4XDN5TZtA4246tFx6X3VqTotWma+YbDmSSXNebTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMZs2HvN4EUXDNUVitAS1wM4t1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AE1qma+DN/d4SXNq4TNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNxT1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAx7ntFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34SF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CNx41w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbbxMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXA+qz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFcttF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACM4SXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNFS1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bXN3zz4G3z+METxAS3N5TMsSXZQhVGEUX3N5TZF3Qox4AFZhXK44V6FSSrxFb5Q70RN5ctF4S+ERN)s6XKHUTnFSSrxFb5Q70RN5cys3pcxMS6FhSAIxAt1qNedRs5ZxTDFqztFMs1HMMT+43PN6XosqNVdhtCN4SXNK4rmqspQ5/R4Y03NUXZNZN7QMz6CD4WNDnaFGsxCDN5+SVAVUtGF3QotMV6d621Vc+ot5NYMqMqt3N1Ne0SmqspQ5/R4Y03NUXZs3NqtxN5Q4SXNK45mqspQ5/R4Y03NUXZs3NGMRV4Q70qIMzzF7r+Q7mRQcV1xxAt1qNedRs5V5nNNUTisAMqtMz6CDTxxFSrmKS+NRs4EA2qVW2CtA4ZERNDx5b1Ne0SmqspQ5/R4Y03NUXZsSXIdqz6CDTxxFSrmKS+ERV)mv2DN5TiM4XItvs)xUVK44VotAS1wM/Rmv2K4ZNStWs2QvNUFh21VqTG1RryZUN4VWsKmZ2osWQPxMStQMNAIFSrmKS+ERV)mv2DMSreQc4VxMS6FhSAIxAtsW+qQ7N2EUMPs3TZs3N1xMS6dvSAIxAtsW+qQ7N2EU4RH6EoQq5adRmR1cSXNebrmqspQ5/Rs6XRNWNEtA4Z+hsDd4SXNebrmqspQ5/RsU4qHWNCQc42HvN2EUAqHWNmF3QoxxN5sWs1xxAttAMqVRV2E62RHUViQKS1w4t6d6SAIxAtt6r21Mz6CRAWNDnaFGsGH7NtF7SAIFSrmKS++7N5ZhzqVcVZM4S1wM/RZhzNN5AttAMqEqzt+4S3HWlKsRrqHhNDx5aPMGNCQcMa+htF4h2RH5TZMxrAxMS6FhSAIxAtt6BaERs)s6zqsSrEt6BaERNUF7S1wWNTsRrqdc5RQ4SWI4rYt5NIHhmRMcVNMK2osWsqFRNDd4SXNDnTNZSrxxN)EWVRH6Nis6t+ZA5DV62NNWNE1qt1wMVw1DAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDN5ztFMQP+MV6d621VDVosA4ZVRs)VU4DMGXGtWtxMRtFx6XK4MctFMs9HMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt7T1Ne0rmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54tF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3bAxMS6d6SAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtnF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nxN3zzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtC1cSXNDnTNZSrxxN)EWVRH6Nis6t+Z6V5V6zqN6Xns3NxMDN/ZSVNxMzz4SzpHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvtF47ANVKNesWS1w4t6d6SAIxAtMZs2HvN4EUXDNA+ot5NYMqz6HGQPHUTCs5trx45RmvSq4Z2YsRtiMqz6HhANwWNZmKS+tvs)Qe0KmZ2asRrGHhETF7SxNDnTNZSrx4A5+hzKV3TZM4EaERN)M4SXNDcGmqspQ5z/MRXK+K2t1RtxMqz6Cc3Ps7c9Qc42tvN5V6A1xxAtF6r2Mht5dSVqwUctFMspHMMT+4SJH5AFsSX+HhN5QhA1Ne0rmqQeE5ETx5bK4MATsA4ZHvNSF7SJt4rEs3N2xvNZEUAR4MACsWmaHMz6CD4WNDnaFSEaZ9b)xWsDMGJo1RtxMcASF7S)Mh2tMZs2HvN2EUJPs3XtFMQctMV6d621wAretWsIZUN)MRS1Ne0Y4S3z+MnUd7s1wAretWsIZUN)mFS1Ne0SmqspQ5z/x6X3VqTEt6rZHMz6CDXAxFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMD+RVWI4re1KsqZUmRE6ARH6NMF3siQ4A/VAVWI4re1KsqZAA4QhXNNWNEMMmqQ5z6CcSAN3zaFGs2xvNZEU4qsStZQq5aQvs)+cVNxMzzN43z+METx6JPVRNEQKt+HhN5QcVNxMzzFGsGHSAFN4SWI4retA4ydRVGE5bK4MAns5t1wvEDxUVqN7At1RrMQvQqEASNwWNns6rqdc5R4SV1NR/R1RryFRNU+43PVKlKFWma49bDM4SXw5TSQRrVQ5/RxU0qVSVEF6r2Mht5ZSV34MAMF3Qod3V6d621VcrosWtZZ5r)m4XDN5TZtA4246t5+D0q4MctF4S+FRNDmxVqHAN6s5t1Q5/RxU0qVSVEF6r2Mht5ZSV34MAMsSX+Q7mRZ703VW2Y1Rt9xMS6NvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNVqATsAMa+ht5+Rz3xMzzNM+z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMaPNW2GtUrbxMS6ZvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAd3z6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFq4wdASXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNx41Ne0yNM+z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFq4tFMQcHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34nF3Qod3MT1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbVxMS61RSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAN5z6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFctSF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACmSSXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFN4N1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5+D0q4MctF4S+wRsDZhAqs3ztmKS+NRs4EA2qN3zzFGsIMRmRmxV3V7ctmKS+NRs4EA2qx3AENMt1wM4t1xAWI4r6scMaM6NwmMnAxMzzN43z+METx5sR4Z2msAz2Z54SF7SAxFSrmKS+NRs4EA2qx3AE4GS1wM4t1xAWI4r6scMaM6NwmMnxN3zzN43z+METx5sR4Z2msAz2ZAttF7SAxFSrmKS+NRs4EA2qVWlRMZQa+3z6CDTxxFSrmKS+NRs4EA2qVW2Ys6tICDN5d4SXx4rS1RrMw6NUFh21Vc+ot5NYMRtF4h2RH5TZM4S1wM4w1RSAIxAt1qNedRs5V5nNNUTisAMqt4ASF7SAxFSrmKS+NRs4EA2qVW2ntU41wM4w1RSAIxAtsW+qQ7N2EWVRsStnMZsZxvVDZhz3N9StF4S+Q7mDZSVNVcNeQc4VxMETxWVKH5Aas3NyMRN/Z3n3N6mRF3Qo+St6d6SAIxAtsW+qQ7N2EUMPs3TZF3QotMV6d621VqTG1RryZA5RmvAqVW2tF3QoQMV6d621VqTG1RryZA5RMDrRV3TEt5NqVqz6CqNAIFSrmKS+Veb)+SVDNUTit6rZQMz6CqNAIFSrmKS+Vc5RVAVNM3TetWsIZAA4VAVRtMzzFGQaVRNtFh21VDTZsUrIZUN4MDXRs7ctFMsV45V6d621VDVeFWS1wMMT1xAWI4rYsRBzxMS6d6SAIxAtt6BaERs)s6zqs3ztF4S+NRN)46Aqs3ztmKS++7N5ZhzqVcVZM4EaNRVD4hA3NUVEMMNyHhN4VU4NtMzzN43z+METxUX3N5TisWsZMcAZEUX3N5TZF3QoxvV)46zqVK2St5t1Q5/R+D0q44ERsRBqtvt5EWsqwAtZQKS1wM4U1xAWI4rYt5NIHhmRMcVNMK2rQRryFRmqE6X1Ne0Y43spHMMT+4S3HWlKsRrqHhNDx5nNVGNaMMmqZ9btF7SxNDnTNZSrxxN)EWVRH6Nis6t+ZA5DV62NNWNEMZs2QvNUF7SXIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3pcxMS6NvSAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtSF3Qo+34S1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFq4tFMspHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGthA1Ne0rmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZAtUF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3pPxMS6d6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADNAtZtUrIMcAtF7Sxx7nTNZSrxxN)EWVRH6Nis6t+Z6V5V6zqN6XnsSXx+45RV6XqIMzz43spHMMT+4SNVqATsAMa+ht54Y03NUXZF3siVeb)d3bqN7AtMZs2HvN4EUXRshzZF3siVeb)d3bqN7AtMZsZw6QDZ3n344VYsRtbxMS6ZFSWNDnaF7rxM6sDZhAqsSrEsAMqw5z6CD4WNDnaF7rZQhVGEA3PsStZF3QoxFbDdMXK4MASs5mqQMzt+4SJH5AFs3NyMRN/d4SXxvASNM+z+METxAmPshVEMZsZw6QDd4SXNq45mqQeE5nbjZqYC9XGdDT7wxQYIYXJt4rEs3N+H7mRZ3b1NRz3s3trxvtGE6z3VqTEM4XIQhV4Z4SXw62t1KsNxMSZQUAWNDnaNZ3z+MVvd6SAIxASN4spHM42Qv21VcraQRt1xM3Rs6X3VStZmKS+NDN5d3nq4MAEt5mzxMSZQUTxFqcTNZSrdStCZvSAIxAyF4spHMMT+x4xx3cTNMAnQ5/R4703mZlKt6rKZUN514SXMR2y43bVHMMT+xTxFqcTNZSrd3Svd6SAIxAS4SzVHM42Qv21Vctot55aERV2EU0qVebtF4VatM4vd6SAIx5zNZ3z+MVvm7AWNDnaNMsV+qV6EhVWI4r6t5NyZ6mDZ3n3N9StF4VadStCZvSAIxAy43bVHMMT+xTX4DnTNZSrt4twZvSAmvAaFGsxdDN2EWsqmZ2otAS1wvrCV4XxNYSrmcQcMStU1xAW4KMzNZ3z+MVvF7VxNYSrs3trxFb5E62DN6NCs3maHMz6H7NAxSAGmqspQ54wMxVWNDnaN4z9+MV6d62ANqcGmqQeQqETx5s3NUTEsKtxZUN514SXMR2y43bVHMMT+xTxFqcTNZSrd3Svd6SAIxAS4SzVHM42Qv21Vctot55aQ9bGEA3PHUctF4VatM4vd6SAIx5zNZ3z+MVvm7AWNDnaNMsV+qV6EhVWI4r6t5NyZUN443n3N9StF4VadStCZvSAIxAy43bVHMMT+xTX4DnTNZSrt4twZvSAmvAaFGsxdDN2EUARHAN/s3maHMz6H7NAxSAGmqspQ54wMxVWNDnaN4z9+MV6d62ANqcGmqQeQqETxAV3VqAttAMqEqz6HGQPHUTCs5trxvmRE6SKIMzzFGsZHvV4VU41xxAtMMmqQ6N)4hAqHUctF4VaxvN4EUEPVDTZFGtIQS5TFh21VRXisA4VmSA5Q70KV34tmKS+Vc5RVAVNM3TetWsIH7mRM4SWI4BR1RrYMqz4Z7EPN62tmKS++hs)1MXq4MAY1RrKMqzt+4Sq4Z2St6r2HvETEhXRHUVttAXbxMETx6lPtMzaF7BeH7mRM4SDshAaFSEaZ6V4QSV3HWNE1qt1wM46ZxVWNDnaFSEaZ6V4QSV3HWNE1cS1wM46ZxAWNDnaFSEaZ6V4QSV3HWNEsU41wM46ZxAWNDnaFSEaZ6V4QSV3HWNEM4S1wM46ZxAWNDnaFSEaZ6V4QSV3HWNEMMNeQS5RV5n34Z2/tU41wvEDxUVqN7At1RrMQvs)mvz3N3zzFU4+Q7mRQR2qs34tFxraxFb/V6z34MTZM4S1wMrSx6XRs3ztFxraxFb)xWsDNANoQc4ZVqrUF7SKVSrGs5trxFb)xWsDMGJo1RtxMRtF4SV3IMzzF3QcxMETx6JPVRNEM44eQSA5V5b1NRz3FU4+tFb)4WVDNUVeFWS1w4tS1xAWI4rS1RrMERt5+Rz3xMzz4G3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MaqQv21VqAtsAEatvND4SVKmZ2nsRrGMcAtF7SAxFSrmKS+QYpRs5nKVSris5NKMcAtF7S1VcroQc49xMETx6X34xToQDEaFRV4mvAqN3zzQKt++RNU+43PHANnsKmax4A/V6AqH6NoMZsxMqz6HhANwWNZmKS+xxN5ZSNDMSVeQD41wvEDxUVqN7At1KQaEqBqEAmPshVEsAMqQ9bDEcSXNDnTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEt6BaERNUF7S1wAtn1RtIHYbSFh21VcrosWtZZ5r)m4XDN5TZtA4246tFx6X3VqTotWma+YbDmSSXNqcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMZs2HvN4EUXDNUVitAS1wM4t1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AE1qma+DN/d4SXNqXTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNxT1Ne0yNZ3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFK4rF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CN4S1w4tt1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbAxMS6NvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAQMz6CcNWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFctUF7SXIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAAC1cSXNqzTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFN4X1Ne0yNxMz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFqXtFMsVHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34MF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CtA4ZERNDx5b1NRz3N4zpHMMT+MNWNDnaNxMz+MVvERSAIx5zmqspQ54t1xAW4K4CmqspQAtU1xAW4DcTNZSrQMV6EhVWI4rtt5NI46tFMRXK+K2Yt5NIMqz6CcSRVcVnQcMqtMzt+43PN6XosqNVxMStxWVqH6NeQRryQMzt+43PN6XosqNVdhtCV4SXNqzTNZSrxFb5Q70RN5cys3b1xMS6VxAWNDnaFGsxCDN5+SVAVUtCF3QotMV6d621Vc+ot5NYMqMqthA1Ne0SmqspQ5/R4Y03NUXZNZN7+qz6CD4WNDnaFGsxCDN5+SVAVUt5F3QotMV6d621Vc+ot5NYMRt5sU43N6AtFMQcN5V6d621Vc+ot5NYMRt5+cVK4vXosWS1wMz/x6X3VRVZFSSrxFb5Q70RNWNEMMNyHhN4VU41Ne0y4S3z+METx5sR4Z2msWmaFDN4MKVqsSrCF3QotMV6d621Vc+ot5NYMRtFZ701Ne0y4S3z+METxWVKH5Aas3NIHSAFZ74RHArGQc4ZdDNtF7S1VqAaQcMqtxmRmvAqN3zaFGsI+eb)d3n34ZmRQq5adRmR1cSXxvA5NZ3z+METxWVKH5AasSX+QhV4Z4SXNqzTNZSrxvmDV6X3mZ2S1RtIMRt5FSSXNDcTNZSrxvmDV6X3mZ2SsRrKCRV2EU0qVebtFMQP+MV6d621VRNesqmqZUN4MDXRs7ctFMQP+MV6d621VRNSs6BqFRV4mvSqmZ2rs6BqM5z6CcS3N6mRFSSrxxN4VWsKmZ2asRrGHhETF7Sxx3XTNZSrxxN)mFS1Ne0rmqspQ5/R+Rz3xMzzNZ3z+METxUX3N5TisWsZMcAtF7S1VqTiMMN2xxN4VWV1xxAtt6BaERs)s6zqsSrE1cJqFRV4EUXDMStasRrIMcA/N4SXNqzTNZSrxxN)EWVRH6Nis6t+ZUN)EWVqN3zzF7BqHvs)sU0NVRAtmKS++7N5ZhzqVcVZM4EadRmRs5bqs7ctFMspHMMT+4S3HWlKsRrqHhNDx5nNVGNaMMmqZ9bUF7SWxYbrmqspQ5/R+D0q44ERsRBqtvtFE7V3VStZs3N1xMS61DAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDMSreQc4VxMS6mhSAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtyF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nAxMzzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCN4SXNDnTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7QMz6CDAWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtE43t1wMMT1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFebtFMspHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvt54SV3w5TZM4S1w4twd6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADMStrMZQqQhmTF7SxNDnTNZSrx45RmvSq4Z2Ys3NxCDN5+SV1NR/R1RryFRNU+4SNVqATsAMa+hsDHSV1NR/R1RryFRNU+4SNVcV/sKtIZUN4MDXRs7ctFMsV45V6d621wAtmsRtIQvNDx5nq4ZN/F3QoQ4tU1xAWI4rM1RtKZ9pRmMbqN3zzFGs2QM/DZhXNVRVZQKS1Q5z/MRXK+K2as6rqQMz6CDXANK4TNZSrxMr)m4XDMSris5NeQMz6CqbAIFSrZ5trxFb)MD4144tStAJqNRs4MRSqtMzzFU4+QYpRs5n3VK2nsRrq45z6HhANwWNZmKS+QYpRs5nN4vXeMMmqZAA5V621Ne0tNMt1Q5/Rm4SqMK2rsc42FRNDN4SXMDXhF7r+Q7mRZ3n3H55zF3QoM3V6d621wAretWsIZUN)MRS1Ne0YNxMz+MnUd7s1wAretWsIZUN)mFS1Ne0YN4zNHMMT+4SNVqATs55a+hs)14SXNK45mqQeE5EDQASNVqATs55a+YbDmSSXNK4rmqspQ5z/x6X3VqTEt6rZHMz6CDXxtFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJas3trxFb)xWsDMSrZMMmqQvtFZhz3HWNSF3QoQMV6d621VqAtsAEaQ45RMDrqNWNSF3QoxFpRE6ARIMzaFGs2QUN4EAXDMStn1RtIMqz6HhANwWNZmKS+Q7N/ZhzDNArSQRtIMRmREUMPN5ctFZsqQ7mD4SVWI4rtt5NI46tFMRXKtMzzQKt++RNU+43PVKlKFWma49bDQqnq4ZNa1R+KxMS6d6SAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqn3HWlKs5t1wMz/4h5Ps3Ti1D41Q5/RxU0qVSVEF6r2Mht5ZSV34MAMsSX+Q7mRZ703VW2Y1Rt9xMS6mhSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNVqATsAMa+ht5+Rz3xMzzN43z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMaPNW2GtUrbxMS6MvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAd3z6CqbWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFq4wdASXNDnTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNx41Ne05mqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAtMzzN4/PHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34nF3QoN5V6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2C43t1wM4t1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMpPxMS6ZvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAM3z6CDTANYSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACmSSXNK45mqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bXN3zz47Mz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNNUTisAMqt4ASF7S)Fq4TNZSrN5V6d62AxYbTNZSrN5V6d62AxFSrmcsVHMMT+xTANYSrmcQcN5V6d62xtFSrmcspHM42Qv21VcrosWtZZ5r)m4XDNUVosA4VxMStxUbRs3Tns6t1xMETx5sR4Z2ms5t1wM/RZSVqVqAGtWtbxMETx5sR4Z2msAz2Z54UF7SAx7nTNZSrxFb5Q70RN5cys3b1xMS6FhSAIxAt1qNedRs5ZxTDFq4tFMs1HMMT+43PN6XosqNVdhtCd4SXNqzTNZSrxFb5Q70RN5cys3bVxMS6FhSAIxAt1qNedRs5ZxTDFebtFMs1HMMT+43PN6XosqmqZ6N/xU03N3zzN4zVHMMT+43PN6XosqmqZUN)V6AR4ZlKF3Qox45RmvSqN5ctmKS+NRs4EA2qVW2CtA4ZERNDFSSXNK4GmqspQ5/R4Y03NUXZsSXxQ6s)ZSVNw54tFMsbHMMT+43PN6XosqmqZ6V4tSSXNqzSmqspQ5/RZ7EPHUTEsA4ZFREDx6/PwWNnsRBaHMz6CcSNVqATsAMa+3zt+4SqVGNet55aQ6N)s6ADNWlRsAS1wMVwVvSAIxAtsW+qQ7N2EUMPs3TZF3QotMV6d621VqTG1RryZA5RmvAqVW2tF3QoQMV6d621VqTG1RryZA5RMDrRV3TEt5NqVqz6CDVWNDnaFGsqQhs5V5n344VYsRtbxMS61DAWNDnaFGsqtvN)V5bK4MATs55a+vN)VA21Ne0tt5NqVqzt+4S34ZmRQq5aQ6s)+RzKIMzz4Sz9HMMT+4S3H55zF3Qot4+T1xAWI4rYsRBzxMS6d6SAIxAtt6BaERs)s6zqs3ztF4S+dRmRs5bqs7ctmKS++7N5ZhzqVcVZM4EaNRVD4hA3NUVEMMNyHhN4VU4NtMzz4S3z+METxUX3N5TisWsZMcAZEUX3N5TZF3QoxvV5V6zqN6Xns6rbxMETxUX3N5TisWsZMcAZEU0qVRNCs6tbxMS6VvSAIxAtt6BaERs)s6zqsSrEMZ+qQAA5V5aPN3zzmc/P+MV6d621VDVosA4ZVRs)VU4DMGXGtWtxMRt5FSSXNebrmqspQ5/R+D0q44ERsRBqtvtFE7V3VStZsSX+QhV4Z4SXNqXTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7d3z6CDXANYSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3b1xMS6FhSAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtCF3Qo+34U1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFDctFMsAHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt7V1Ne0YNM+z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtC1cSXxvAnmqspQ5/R+D0q44ERsRBqtvtFQcVRH6EoQq5aNRN)46Aqs3ztFMsV+MV6d621VDVosA4ZVRs)VU4DMhVZsRrKCRV2E5bNVSrZ1RrbxMS61DAWNDnaF7r+Q7mRZ703VW26scMaM6NUF7SqVqAaMMNVQ5z/x6X3VqTot6rZwvNUF7SqVqAaMMNVQ5z/x6zqN6Xns3NyH7N)MRA1Ne0GFM+z+METx5bRNAVnQcMqtvt5ZSVqtMzz43+z+METxAmPshVE1Ks2FRNUF7S1VqAnFGtIQS5RQcVKIMzaF7rZQhVGE62qH6NnF3Qo+3461RSAIxAtF6r2MhtFx6zqN6XnF3QoFctS1xAEN7At1cX+dRV)4Y0RHAN/F3sitq/Rm4SqMK2TtAXIHhN/EcSXw5TSQRrVQ5/Rm4SqMK2rsc42FRmqE5bqHUAtF4S1d3zt+43PHABRsSJeCebD4SVNtMzzHAXax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMD+RVWI4re1KsqZA5RV5bqs3TEQc4Z+hNDFSSXNq4TNZSrxFb)xWsDM3TSsRrKw6NDFSSXx4rYsRtxFqzt+43PHUTatAXKZAAFZhXK4MctFxrItvV)Zv21VqATQc4ZZ9b/xUVK4ZmRtAX+NRNUF7SqVqAaMMNVQ5/RxU0qVSVEF6r2M3z6HhANwWNZmKS+xxN5ZSNDMSVeQDEaERN)dhXJN3zzNZ3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWma+7N5ZSV1Ne0tM4XIQhV4Mqs1xxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNVqATsAMa+ht5+RXJIMzz4S3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmatFb)4WV3NUVEt6rZHMz6CD4WNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaNDNFV6SKIMzzNxMz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFK4tFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34yNZS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMb1xMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAFqz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFc+TF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACZ4SXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNMN1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxtMzz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFqXtFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34MF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CtA4ZERNDx5b1NRz34G3z+MVvdvSAIxAnmqspQA+T1xAW4DcTNZSrQMV6d62xIFSrmcsbHMMT+vAWNDna4G3z+vtU+43PVKlKFWma49bDQqn3HWlKs5t1wMz/4h5Ps3Ti1D41Q5/R4Y03NUXZF3QoxvN4VWQPsGNaQKS1Q5/R4Y03NUXZNZN7d3z6CD4WNDnaFGsxCDN5+SVAVUtSF3QotMV6d621Vc+ot5NYMqMqt3b1Ne0SmqspQ5/R4Y03NUXZNZN7QMz6CDTAIFSrmKS+NRs4EA2qx3AE43t1wM4t1xAWI4r6scMaM6NwmMnxxMzzN43z+METx5sR4Z2msWmaVc5REUX1Ne0y4S3z+METx5sR4Z2msWma+hNDZY03NUctF4S+tFb)4UrqN3zaFGsxCDN5+SVDMStasRrIMcAtF7SAxYbTNZSrxFb5Q70RNWNEMMNyHhN4VU4NtMzzN43z+METx5sR4Z2msWmaQxNSF7SAxYbTNZSrxvmDV6X3mZlKsRtxQ45RMcSKs3Tit5mzxMStx6X3V3TZMZsMQhV4Z4SWI4BKQRr2Q6t5dSVqw5TEt5NqVqz6CDXxNDnTNZSrxvmDV6X3mZ2S1RtIMqz6CD4WNDnaFGsI+eb)d3nNVqAnsWmaxMz6CRAWNDnaFGsI+eb)d3nNVcV/sKtIZUN5sWs1Ne05NZ3z+METxWQPHUXZs3NyH7N)MRA1Ne05NZ3z+METxWsNVKNZM4XIQ7mRZ3nN4ZNZsD41wM/REWsqxMzaFGsyMRN/Z3n344VYsRtbxMS61DAWNDnaFGsGQ3BTF7SAIFSrmKS++hs)14SXNDnTNZSrxxN)EWVRH6Nis6t1xMStxWVRsSte1KsyMRmTFh21VDVosA4ZVRs)VU4DNAtGM4XIdDmqE5b344EKs6t+Fqz6CDVWNDnaFGsGdRN4MKsRHWNSs3NGdRN4Z4SXx4r6QRtxQxN5Q4SWI4rYt5NIHhmRMcVNMK2osWsqFRNDd4SXNDnTNZSrxxN)EWVRH6Nis6t+ZA5DV62NNWNE1qt1wMVw1DAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDN5ztFMQP+MV6d621VDVosA4ZVRs)VU4DMGXGtWtxMRtFx6XK4MctFMs9HMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt7T1Ne0nmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54tF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3bAxMS6MvSAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtnF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nxN3zzmc/cHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt3N1Ne0rmqspQ5/R+D0q44ERsRBqtvtFQcVRH6EoQq5aNRN)46Aqs3ztFMsV+MV6d621VDVosA4ZVRs)VU4DMhVZsRrKCRV2E5bNVSrZ1RrbxMS61DAWNDnaF7r+Q7mRZ703VW26scMaM6NUF7SqVqAaMMNVQ5z/x6X3VqTot6rZwvNUF7SKVSrGs5trx45RMDrRV3TEtA4Z+hsDd4SXNebrmqspQ5z/4S2Rs3Tns6t+Z6N4VUr1Ne0n43+z+METxAmPshVE1Ks2FRNUF7S1VqAnFGtIQS5RQcVKIMzaF7rZQhVGE62qH6NnF3Qo+MV6d621wAVeQDEatvs)Qe0KIMzzNZ3z+MnU+4SqVqAms6ryQhNSF7SJt4re1KsqZUmRE6ARH6NMF3siQ4A/VAVWI4re1KsqZAA4QhXNNWNEMMmqQ5z6CcSAN3zaFGs2xvNZEUAR4MACs6tAxMSZ+7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJas3trxFb)xWsDMSrZMMmqQvtFZhz3HWNSF3QoFqV6d621VqAtsAEaQ45RMDrqNWNSF3QoxxN)MqbNtMzaFGs2QUN4EAXDMStn1RtIMqz6HhANwWNZmKS+Q7N/ZhzDNArSQRtIMRmREUMPN5ctFZsqQ7mD4SVWI4rtt5NI46tFMRXKtMzzQKt++RNU+43PVKlKFWma49bDQqnq4ZNa1R+KxMS6d6SAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqn3HWlKs5t1wMz/4h5Ps3Ti1D41Q5/RxU0qVSVEF6r2Mht5ZSV34MAMsSX+Q7mRZ703VW2Y1Rt9xMS61RSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNVqATsAMa+ht5+Rz3xMzzN43z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMaPNW2GtUrbxMS6NvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAd3z6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFq4wdASXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNx41Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAtMzz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFDctFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34GF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2C4SS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbNxMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXA1Mz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFqSUF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAA5dhzq4ZNSMx41wvrCdvSAIxAnmqspQA+T1xAW4DcTNZSrQMV6d62xIFSrmcsbHMMT+vAWNDna4G3z+MVvdvSAmvAaFGs+dRmDMqnJH5AFs3NGdRN4Z4SXx4rPsRtIQvNDFSSWI4r6scMaM6NUF7S1VqTZsWs2+DmDd4SWI4r6scMaM6NwmMnAN3zz4G3z+METx5sR4Z2msAz2Z54tF7SxIFSrmKS+NRs4EA2qx3AENx41w4+T1xAWI4r6scMaM6NwmMnxIMzz4G3z+METx5sR4Z2msAz2ZAtUF7SxIFSrmKS+NRs4EA2qx3AE4SS1w4+T1xAWI4r6scMaM6mqEWsNVK2YF3Qo1MV6d621Vc+ot5NYMRt5+cVK4vXosWS1wMz/x6X3VRVZFSSrxFb5Q70RNWNEMMNyHhN4VU41Ne0y4S3z+METx5sR4Z2msWmaFDN4MKVqsSrCF3QotMV6d621Vc+ot5NYMRtFZ701Ne0y4S3z+METxWVKH5Aas3NIHSAFZ74RHArGQc4ZdDNtF7S1VqAaQcMqtxmRmvAqN3zaFGsI+eb)d3n34ZmRQq5adRmR1cSXxvA5NZ3z+METxWVKH5AasSX+QhV4Z4SXNqzTNZSrxvmDV6X3mZ2S1RtIMRt5FSSXNDcTNZSrxvmDV6X3mZ2SsRrKCRV2EU0qVebtFMQP+MV6d621VRNesqmqZUN4MDXRs7ctFMQP+MV6d621VRNSs6BqFRV4mvSqmZ2rs6BqM5z6CcSN4ZNZsDMeVeb)+SV1xxAttAMqVRV2E62RHUViQKS1w4t6d6SAIxAtt6r21Mz6CqNAIFSrmKS++hs)14SXxvA5NZ3z+METxUX3N5TisWsZMcAtF7S1VqTiMMN2xxN4VWV1xxAtt6BaERs)s6zqsSrE1cJqFRV4EUXDMStasRrIMcA/N4SXNqzTNZSrxxN)EWVRH6Nis6t+ZUN)EWVqN3zzF7BqHvs)sU0NVRAtmKS++7N5ZhzqVcVZM4EadRmRs5bqs7ctFMspHMMT+4S3HWlKsRrqHhNDx5nNVGNaMMmqZ9bUF7SWxYbrmqspQ5/R+D0q44ERsRBqtvtFE7V3VStZs3N1xMS61DAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDMSreQc4VxMS6mhSAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtyF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nAxMzzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCN4SXNDnTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7QMz6CDAWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtE43t1wMMT1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFebtFMspHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvt54SV3w5TZM4S1w4twd6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADMStrMZQqQhmTF7SxNDnTNZSrx45RmvSq4Z2Ys3NxCDN5+SV1NR/R1RryFRNU+4SNVqATsAMa+hsDHSV1NR/R1RryFRNU+4SNVcV/sKtIZUN4MDXRs7ctFMQP+MV6d621wAtmsRtIQvNDx5nq4ZN/F3QoQ4tU1xAWI4rM1RtKZ9pRmMbqN3zzFGs2QM/DZhXNVRVZQKS1Q5z/MRXK+K2as6rqQMz6CDXAxGVTNZSrxMr)m4XDMSris5NeQMz6CqbAtFSrZ5trxxN4VUrRs7c91RBcxMS/QA3PHABRs3NMdRV4MKsJN3zzQKt++RNU+43PHABRsSJeCebD4SVDMStZtWS1wMz6V4SWI4re1KsqZAA4QhXNNWNCF3sit5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEV6AaFGs2xvNZEU4qsStZQq5aQvs)+cVNxMzzNxMz+METx6JPVRNEQKt+HhN5QcVNxMzzFGsGHSAFN4SWI4retA4ydRVGE5bK4MAns5t1wvEDxUVqN7At1RrMQvQqEASNwWNns6rqdc5R4SV1NR/R1RryFRNU+43PVKlKFWma49bDM4SXw5TSQRrVQ5/RxU0qVSVEF6r2Mht5ZSV34MAMF3Qo+MV6d621VcrosWtZZ5r)m4XDN5TZtA4246t5+D0q4MctF4S+FRV4mvARH54tmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2S1RrMEDN5+qn3H55zF3QoN5V6d621VcrosWtZZ5r)m4XDN5TZtA4246tFx6X3VqTotWma+hs)14SXNqzTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdht5470KHANnF3QoFqV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CNMt1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMpc+Mz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFq4tF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACN4SXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNvA1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxN3zz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFebtFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34FF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CFZS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMpKxMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXxQ6s)ZSVNw54tF4VaQMV6d62xIFSrmcsbHMMT+vAWNDna4G3z+MVvdvSAIxAnmqspQA+T1xAW4DcTNZSrQMV6EhVWI4rtt5NI46tFMRXK+K2Yt5NIMqz6CcSRVcVnQcMqtMzt+43PN6XosqNVxMStxWVqH6NeQRryQMzt+43PN6XosqNVdhtCV4SXNqzTNZSrxFb5Q70RN5cys3b1xMS6FhSAIxAt1qNedRs5ZxTDFq4tFMs1HMMT+43PN6XosqNVdhtCd4SXNqzTNZSrxFb5Q70RN5cys3bVxMS6FhSAIxAt1qNedRs5ZxTDFebtFMs1HMMT+43PN6XosqmqZ6N/xU03N3zzN4/PHMMT+43PN6XosqmqZUN)V6AR4ZlKF3Qox45RmvSqN5ctmKS+NRs4EA2qVW2CtA4ZERNDFSSXNK45mqspQ5/R4Y03NUXZsSXxQ6s)ZSVNw54tFMs1HMMT+43PN6XosqmqZ6V4tSSXNK45mqspQ5/RZ7EPHUTEsA4ZFREDx6/PwWNnsRBaHMz6Cc3PHUTns6t+HFbDZSV1xxAtsW+qQ7N2E62qH6Nns3maVRNtF7SWxYbrmqspQ5/RZ7EPHUTEMZs2QvNUF7SAxFSrmKS+ERV)mv2DMSreQcMqZ9btF7SxIFSrmKS+ERV)mv2DMSris5NeQvt5EWsqxMzz43spHMMT+4SqVqAmsWmaQ6s)+RzKIMzz43spHMMT+4SqwArZs6txQFb)4WVDMGXZs6raxMStxUAqHWNmFS4qQhs5Z4SWI4ras6rqQvt5dhz3HAVnF3QoN5MT1xAWI4rY1Rt9xMS6d6SAIxAtt6rZHMz6CDAWNDnaFGsGdRN4MKsRHWNSF3QoxvN4MqpPHAras6rbxMETxUX3N5TisWsZMcAZE5sKsStnt5NGZAA5dhzq4ZNSMx41wM4t1xAWI4rYt5NIHhmRMcVNMK2Yt5NIMqz6CcSKHANisWQatxNUFh21VDVosA4ZVRs)VU4DNWlRsUrxMRETF7SAIFSrmKS++7N5ZhzqVcVZM4Ea+vV)d3bqVW2eF3Qo+St6d6SAIxAtt6BaERs)s6zqsSrEMZ+qQAA5V5aPxMzz43spHMMT+4S3HWlKsRrqHhNDx5nNVGNaMMmqZA5RmvAqN3zzFZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCV4SXNDnTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7tMz6CDAWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtENx41wMMT1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFDctFMspHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt7V1Ne0rmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZAttF7SAIFSrmKS++7N5ZhzqVcVZM4EaMhN)MDrRV3TE1qmqHvV4VU41Ne0GNZ3z+METxUX3N5TisWsZMcAZEAXqHAV/sKtIZAAFE74qH55KF3QoN5MT1xAWI4rS1RrMEDN5+qaPN6XosqNVxMS/Z74KH5caF7r+Q7mRZ703HAVzs5t1wvmRmv2NN5caF7r+HhN5QhADNUTit6rZQMz6CqNAIFSrmKS+FRs5MRAK4ZNSs3NIMRNSF7Sx4qcTNZSrxMr)m4XDNAreMMNVxMStx623NAtetW3eN6s)VAX1xxAtF6r2Mht5dSVqwUctF4Snd3Svd6SAIxAtF6r2MhtFx6zqN6XnF3Qo+34wm7AWNKJamKS+tvV)46SRHAN/F3sitq/Rm4SqMK2TtAXIHhN/EcSXw5TSQRrVQ5/Rm4SqMK2rsc42FRmqE5bqHUAtF4S1d3zt+43PHABRsSJeCebD4SVNtMzzHAXax45RmvSqmZ2Y1Rt9xMS6MvSAIxAtMZs2HvN2EUXRH9StF4SnFqV6EG2WVh2tMZs2HvN2EUJPs3XtFMQctMV6d621wAretWsIZUN)MRS1Ne0YFM+z+MnUd7s1wAretWsIZUN)mFS1Ne0yNZ3z+METxUMPHAmKs3NGH7NtF7SAtFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJas3trxFb)xWsDMSrZMMmqQvtFZhz3HWNSF3QotMV6d621VqAtsAEaQ45RMDrqNWNSF3QoxFpRE6ARIMzaFGs2QUN4EAXDMStn1RtIMqz6HhANwWNZmKS+Q7N/ZhzDNArSQRtIMRmREUMPN5ctFZsqQ7mD4SVWI4rtt5NI46tFMRXKtMzzQKt++RNU+43PVKlKFWma49bDQqnq4ZNa1R+KxMS6d6SAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqn3HWlKs5t1wMz/4h5Ps3Ti1D41Q5/RxU0qVSVEF6r2Mht5ZSV34MAMsSX+Q7mRZ703VW2Y1Rt9xMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNVqATsAMa+ht5+Rz3xMzzNM+z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMaPNW2GtUrbxMS6NvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAd3z6CqNWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFq4wdASXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNx41Ne0yNZ3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFq4tFMs9HMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34nF3Qod34t1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbVxMS61RSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAN5z6CD4WNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFctSF7SAxSATNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNFS1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bXN3zz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNNUTisAMqt4ASF7S)FebTNZSrd3MT1xAW4qXTNZSrd34t1xAW4ebTNZSrtMV6d62AxSATNZSrQMV6d62xIFSrmcsbHM42Qv21VcrosWtZZ5r)m4XDNUVosA4VxMStxUbRs3Tns6t1xMETx5sR4Z2ms5t1wM/RZSVqVqAGtWtbxMETx5sR4Z2msAz2Z54UF7SAxSATNZSrxFb5Q70RN5cys3b1xMS6VxAWNDnaFGsxCDN5+SVAVUtCF3QotMV6d621Vc+ot5NYMqMqthA1Ne0SmqspQ5/R4Y03NUXZNZN7+qz6CD4WNDnaFGsxCDN5+SVAVUt5F3QodS+T1xAWI4r6scMaM6mqEWsNVK2YF3QoN5V6d621Vc+ot5NYMRt5+cVK4vXosWS1wMz/x6X3VRVZFSSrxFb5Q70RNWNEMMNyHhN4VU41Ne0y4S3z+METx5sR4Z2msWmaFDN4MKVqsSrCF3Qo+qV6d621Vc+ot5NYMRtFZ701Ne0y4S3z+METxWVKH5Aas3NIHSAFZ74RHArGQc4ZdDNtF7S1VqAaQcMqtxmRmvAqN3zaFGsI+eb)d3n34ZmRQq5adRmR1cSXxvA5mqspQ5/RZ7EPHUTEMZs2QvNUF7SxIFSrmKS+ERV)mv2DMSreQcMqZ9btF7SxIFSrmKS+ERV)mv2DMSris5NeQvt5EWsqxMzzN4z1HMMT+4SqVqAmsWmaQ6s)+RzKIMzz43spHMMT+4SqwArZs6txQFb)4WVDMGXZs6raxMStxU0qVebtmKS+Q6N)s6ADNUTit6rZQMz6CDVXNYSrmKS++YbDmSSXNDcTNZSrxxN)MRS1Ne0YN43z+METxUX3N5TisWsZMcAtF7S1VqTiMMN2xxN4VWV1xxAtt6BaERs)s6zqsSrE1cJqFRV4EUXDMStasRrIMcA/N4SXNDcTNZSrxxN)EWVRH6Nis6t+ZUN)EWVqN3zzFGsx+cAFZ703N3zaFGsGdRN4MKsRHWNSs3maVRN/4SVKIMzzmczAHMMT+4S3HWlKsRrqHhNDx5nNVGNaMMmqZ9bUF7SWxYbrmqspQ5/R+D0q44ERsRBqtvtFE7V3VStZs3N1xMS61DAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDMSreQc4VxMS6mhSAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtyF3Qo45V6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nAxMzzmc/c1MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nAtMzzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCd4SXNKVTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7+qz6CDAWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtE4SS1wMMT1xAWI4rYt5NIHhmRMcVNMK2Fs6rZw6QDZ3aPNWNTQcMqtMz6CDVAIFSrmKS++7N5ZhzqVcVZM4EaMhN)MDrRV3TEM4JetvN)mZV1Ne05NZ3z+METxUMPHAmKt5NGZ9b5Q70RN5ctFxrItvV)Zv21wAretWsIdDN)MDSqN3zzQKt++RNU+4SNVcV/sKtIZUN4MDXRs7ctFMsV1MV6d621wAtmsRtIQvNDx5nq4ZN/F3Qo+qV6d621wAVeQDEaxFbD4SV1Ne0t1RtbmhV4mx4qNWNnFSSrxMr)m4XDNUTZsUrbxMStQx4xIFSrmKS+49bDQqnNVcV/sKtbxMS6NMbWNKJamKS+FDN4EAXRHAN/F3sitq/Rm4SqMK2TtAXIHhN/EcSXw5TSQRrVQ5/Rm4SqMK2rsc42FRmqE5bqHUAtF4S1d3zt+43PHABRsSJeCebD4SVNtMzzHAXax45RmvSqmZ2Y1Rt9xMS6MvSAIxAtMZs2HvN2EUXRH9StF4SnQMV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2DN7At1Rr+VRtFxAVNNWNnsSXIH7N)VU41Ne0ymqspQ5/Rm4SqMK2nMZsZw6N5VU41Ne0t1KQaQvQTFh21VqAatAMaMhtF4h5Ps3TZF3siQ4A/VAVWI4retUrIHht5xU4Ks3TZsWQatFb5Z4SXVRNetWtxMqETxAS3N5TMsSXZQhVSF7SKVSrGs5trxFpREWVJVW2M1RtKZ6N4V6lPsGVtFMspHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZUN)EWVqN3zzF7rxQFbDZh/PtMzaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMSretWsIdDmqEUJPs3XtFMQcFqV6d621VcrosWtZZ5r)m4XDN5TZtA4246tFx6X3VqTotWma+hs)14SXNqzTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdht5470KHANnF3QoM3V6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CNMt1w4tU1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMpc+Mz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFq4tF7SAx3zTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFNMb1Ne0GmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxIMzzNxMz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFqctFMQcFqV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2C4SS1wM4U1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbNxMS6MvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXA1Mz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFqSUF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAA5dhzq4ZNSMx41wvrCZvSAIxAyN43z+MVvZvSAIxACmqspQ54wNvSAIxAymqspQAtS1xAW4DcTNZSrQMV6d62xIFSrs3trxFpREWVJVW2M1RtKZUN)EWVqN3zzFGsiHhEDZSVNxMzaFGsxCDN5+SV1Ne0tsAMqVebDV62KIMzaFGsxCDN5+SVAVUtyF3QotMV6d621Vc+ot5NYMqMqt741Ne0SmqspQ5/R4Y03NUXZNZN7Fqz6CD4WNDnaFGsxCDN5+SVAVUtnF3QotMV6d621Vc+ot5NYMqMqt7V1Ne0yNZ3z+METx5sR4Z2msAz2ZAttF7SAxFSrmKS+NRs4EA2qVWlRMZQa+3z6CDTxxFSrmKS+NRs4EA2qVW2Ys6tICDN5d4SXx4rS1RrMw6NUFh21Vc+ot5NYMRtF4h2RH5TZM4S1wM4w1RSAIxAt1qNedRs5V5nNNUTisAMqt4ASF7SAxFSrmKS+NRs4EA2qVW2ntU41wM4w1RSAIxAtsW+qQ7N2EWVRsStnMZsZxvVDZhz3N9StF4S+Q7mDZSVNVcNeQc4VxMETxWVKH5Aas3NyMRN/Z3n3N6mRF3Qo+St6d6SAIxAtsW+qQ7N2EUMPs3TZF3QotMV6d621VqTG1RryZA5RmvAqVW2tF3QoQMV6d621VqTG1RryZA5RMDrRV3TEt5NqVqz6CqNAIFSrmKS+Veb)+SVDNUTit6rZQMz6CqNAIFSrmKS+Vc5RVAVNM3TetWsIZAA4VAVRtMzzFGQaVRNtFh21VDTZsUrIZUN4MDXRs7ctFMsV45V6d621VDVeFWS1w4tS1xAWI4rYsRBzxMStQMNWNDnaFGsGdRN4MKsRHWNSF3QoxxN5sWsNNWNnFSSrxxN)EWVRH6Nis6t+Z9bFV5bK4Z2YsSXxQ6s)ZSVNw54tFMsVHMMT+4S3HWlKsRrqHhNDx5n3HWlKs5t1wMz/V6SRH6NoMZsnxMETxUX3N5TisWsZMcAZEU0qVRNCs6tbxMStQxTWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDNW4tF4SnN5MT1xAWI4rYt5NIHhmRMcVNMK2rQRryFRmqEAS1Ne05NZ3z+METxUX3N5TisWsZMcAZEUAKHUTCsWmatFbDZSV1NefzmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54UF7SWxG4SmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54tF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3bAxMS6d6SAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtnF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nxN3zzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtC1cSXNDnTNZSrxxN)EWVRH6Nis6t+Z6V5V6zqN6Xns3NxMDN/ZSVNxMzz4SzpHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvtF47ANVKNesWS1w4t6d6SAIxAtMZs2HvN4EUXDNA+ot5NYMqz6HGQPHUTCs5trx45RmvSq4Z2YsRtiMqz6HGQPHUTCs5trx45RMDrRV3TEtA4Z+hsDd4SXNqqzmqspQ5z/4S2Rs3Tns6t+Z6N4VUr1Ne0yNZ3z+METxAmPshVE1Ks2FRNUF7S1VqAnFGtIQS5RQcVKIMzaF7rZQhVGE62qH6NnF3Qo+34CmhSAIxAtF6r2MhtFx6zqN6XnF3QoQM4t1xAEN7AtMMNMMeb)+hz3VcAtFxraxFb)xWsDNANoQc4ZVqrUF7SKVSrGs5trxFb)xWsDMGJo1RtxMRtF4SV3IMzzF3QcxMETx6JPVRNEM44eQSA5V5b1NRz3FU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE5EDQASNVqATs55a+YbDmSSXNDnTNZSrx45RmvSqmZ2YsRBzxMS6d6SAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MaqQv21VqAtsAEatvND4SVKmZ2nsRrGMcAtF7SAtFSrmKS+QYpRs5nKVSris5NKMcAtF7S1VDViM4XAxMETx6X34xToQDEaFRV4mvAqN3zzQKt++RNU+43PHANnsKmax4A/V6AqH6NoMZsxMqz6HGQPHUTCs5trxFpREWVJVW2M1RtNxMS/Z74KH5caFGs+dRmDMqnJH5AFs3NIMDN4m4N1Ne0rmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMs3NGdRN4Z4SXx4rCQc42Qvs)N4SWI4rtt5NI46tFMRXK+KlKs6ryQ3BqEUMPHAmKt5NGZUN)mFS1Ne05mqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSX+Q7mRZ703VW2YsRBzxMS6FhSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNys3NxdRV)46A1Ne0CmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bAN3zz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFK4rF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CN4S1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMbAxMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXAQMz6CRAWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFctUF7SxIFSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAAC1cSXNDcTNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEMMmqdhtFN4X1Ne0nmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bXIMzz4G3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFKVtFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDMStasRrIMcA/N4SXMR2nmqspQA+T1xAW4DcTNZSrQMV6d62xIFSrmcsbHMMT+vAWNDna4G3z+MVvdvSAIxAnmqQeQqETxAS3N5TMsSXZQhVGEUX3N5TZF3Qox4AFZhXK44V6FSSrxFb5Q70RN5ctF4S+ERN)s6XKHUTnFSSrxFb5Q70RN5cys3pcxMS6FhSAIxAt1qNedRs5ZxTDFqztFMs1HMMT+43PN6XosqNVdhtCN4SXNK4rmqspQ5/R4Y03NUXZNZN7QMz6CD4WNDnaFGsxCDN5+SVAVUtGF3QotMV6d621Vc+ot5NYMqMqt3N1Ne0SmqspQ5/R4Y03NUXZs3NqtxN5Q4SXNK45mqspQ5/R4Y03NUXZs3NGMRV4Q70qIMzzF7r+Q7mRQcV1xxAt1qNedRs5V5nNNUTisAMqtMz6CDTxxFSrmKS+NRs4EA2qVW2CtA4ZERNDx5b1Ne0SmqspQ5/R4Y03NUXZsSXIdqz6CDTxxFSrmKS+ERV)mv2DN5TiM4XItvs)xUVK44VotAS1wM/Rmv2K4ZNStWs2QvNUFh21VqTG1RryZUN4VWsKmZ2osWQPxMStQMNAIFSrmKS+ERV)mv2DMSreQc4VxMS6FhSAIxAtsW+qQ7N2EUMPs3TZs3N1xMS6dvSAIxAtsW+qQ7N2EU4RH6EoQq5adRmR1cSXNebrmqspQ5/Rs6XRNWNEtA4Z+hsDd4SXNebrmqspQ5/RsU4qHWNCQc42HvN2EUAqHWNmF3QoxxN5sWs1xxAttAMqVRV2E62RHUViQKS1w4t6d6SAIxAtt6r21Mz6CRAWNDnaFGsGH7NtF7SAIFSrmKS++7N5ZhzqVcVZM4S1wM/RZhzNN5AttAMqEqzt+4S3HWlKsRrqHhNDx5aPMGNCQcMa+htF4h2RH5TZMxrAxMS6FhSAIxAtt6BaERs)s6zqsSrEt6BaERNUF7S1wWNTsRrqdc5RQ4SWI4rYt5NIHhmRMcVNMK2osWsqFRNDd4SXNDnTNZSrxxN)EWVRH6Nis6t+ZA5DV62NNWNE1qt1wMVw1DAWNDnaFGsGdRN4MKsRHWNSsSJe+DmD4SVDN5ztFMQP+MV6d621VDVosA4ZVRs)VU4DMGXGtWtxMRtFx6XK4MctFMs9HMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt7T1Ne0rmqspQ5/R+D0q44ERsRBqtvtF4h2RH5TZMxrxZ54tF7SAIFSrmKS++7N5ZhzqVcVZM4EaFDN4MKVqsSrCs3bAxMS6d6SAIxAtt6BaERs)s6zqsSrEMMNyHhN4VU4N+DtnF3Qo+MV6d621VDVosA4ZVRs)VU4DMStasRrIMcA/43nxN3zzNZ3z+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtC1cSXNDnTNZSrxxN)EWVRH6Nis6t+Z6V5V6zqN6Xns3NxMDN/ZSVNxMzz4SzpHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvtF47ANVKNesWS1w4t6d6SAIxAtMZs2HvN4EUXDNA+ot5NYMqz6HGQPHUTCs5trx45RmvSq4Z2YsRtiMqz6HhANwWNZmKS+tvs)Qe0KmZ2asRrGHhETF7SxNDnTNZSrx4A5+hzKV3TZM4EaERN)M4SXNDcGmqspQ5z/MRXK+K2t1RtxMqz6Cc3Ps7c9Qc42tvN5V6A1xxAtF6r2Mht5dSVqwUctFMspHMMT+4SJH5AFsSX+HhN5QhA1Ne0rmqQeE5ETx5bK4MATsA4ZHvNSF7SJt4re1KsqZUmRE6ARH6NMF3siQ4A/VAVWI4re1KsqZAA4QhXNNWNEMMmqQ5z6CcSAN3zaFGs2xvNZEUAR4MACs6tAxMSZ+7s1wAretWsIZUN)mFS1Ne0yN43z+METxUMPHAmKs3NGH7NtF7SWxYbTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAxFSrmKS+tFb)4WVDNUVitAS1wMVwFhSAVhAaFU4+tFb)4WVDNUVeFWS1wMMT1xAWI4rS1RrMERt5+Rz3xMzzNZ3z+MnUd7s1wAretWsIZUN)mFS1Ne0rmqspQ5z/x6X3VqTEt6rZHMz6CDAWNKJamKtax45RmvSqmZ2Y1Rt9xMS6d6SAIxAtMZs2HvN2EUXRH9StFMspHMMDQv2Jt4rS1RrMERt5+RXJIMzzNZ3z+METxUMPHAmKs3NGH7NtF7SAIFSrZ5tytqz/x6X3VqTEt6r21Mz6CDAWNDnaF7r+Q7mRZ3n3HAVTF3Qo+MV6EG2WVh2tMZs2HvN2EUJPs3XtFMspHMMT+4SNVqATs55a+hs)14SXNDnTNZtnQ5rSxUMPHAmKs3NGQ3BTF7SAIFSrmKS+tFb)4WVDNUVitAS1wMMT1xAEN7ThF7r+Q7mRZ3n3H55zF3Qo+MV6d621wAretWsIZUN)MRS1Ne0rmqQeE6tU+43PHABRsSX+McA5V6ADM3Tit6BqtMz6CD4WNDnaFGs2xvNZE6ANVcV/s5mqtMz6CcS3HAVCMx41Q5/Rmv234Z2FsSXxQFbDZSV1NRznMxBqMqETx6X3w5Tis3N+tvVDZSVqVK2S1qNVxM3Rs6X3VStZmKS+xxN5ZSNDMSVeQD41wvEDxUVqN7At1KQaEqBqEAmPshVEsAMqQ9bDEcSXNK4TNZSrxFpREWVJVW2M1RtKZ6N4V6lPsSVEt6BaERNUF7S1wAtZMv+qMDmR4SV1xxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNVqATsAMa+ht5+RXJIMzzNxMz+METxAS3N5TMsSXZQhVGEWVqHUTeFWmatFb)4WV3NUVEt6rZHMz6CDTWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaNDNFV6SKIMzz43+z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFK4tFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34yNZS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMb1xMS6VxTWNDnaFGs+dRmDMqnJH5AFs3NIMDN4m4NDMStZMZmaFq4SF7SANYSrmKS+xxN5ZSNDMSVeQDEaERN)dhXJVW2Cs6t2ZAACd4SXNK4rmqspQ5/RxU0qVSVEF6r2Mht5ZSV34MAMsSXxMc5qE5bxN3zz4S3z+METxAS3N5TMsSXZQhVGEWVqHUTeFWmaFRNDmMnNFebtFMsbHMMT+43PVKlKFWma49bDQqnq4ZNa1RtZZAA5VUTDM34FF3QoQMV6d621VcrosWtZZ5r)m4XDN5TZtA4246tF4SVNVW2CFZS1w4+T1xAWI4rtt5NI46tFMRXK+KlKs6ryQ3BqE5bqs3AEMMpKxMS6dvSAIxAt1KQaEqBqEAmPshVEsAMqQ9bDMqnNNWNysSXxQ6s)ZSVNw54tF4VaQMV6d62AxG4TNZSrd3V6d62Ax7nTNZSrN5V6d62xIFSrmcsbHMMT+vAWNDna4G3z+MVvdvSAmvAaFGs+dRmDMqnJH5AFs3NGdRN4Z4SXx4rPsRtIQvNDFSSWI4r6scMaM6NUF7S1VqTZsWs2+DmDd4SWI4r6scMaM6NwmMnAN3zzN43z+METx5sR4Z2msAz2Z54tF7SAxFSrmKS+NRs4EA2qx3AENx41wM4t1xAWI4r6scMaM6NwmMnxIMzzN43z+METx5sR4Z2msAz2ZAtUF7SAxFSrmKS+NRs4EA2qx3AE4SS1wM4t1xAWI4r6scMaM6mqEWsNVK2YF3QodStt1xAWI4r6scMaM6mqEUXqs3)ot5NbxMStxUMPHAN/s5t1Q5/R4Y03NUXZsSXxQ6s)ZSVNxMzzN4/PHMMT+43PN6XosqmqZAA5dhzq4ZNSMx41wM4t1xAWI4r6scMaM6mqE6A3tMzzN4/PHMMT+4SqVGNet55aERsD4hANVcVtQRtIH7N514SXx4retWtIMc5R46XK4MctmKS+ERV)mv2DNUTZsUrIZUN5sWs1Ne0Y43spHMMT+4SqVGNet55atFbDZSV1Ne0SmqspQ5/RZ7EPHUTEMZs2QvmqEAS1Ne0nmqspQ5/RZ7EPHUTEMZsZw6QDZ3n3N6mRF3QoN5MT1xAWI4BR1RrYMRt5dhz3HAVnF3QoN5MT1xAWI4BRMZQqMcAFZhX3VqTEM4MqMRsSF7S1VKlRsAS1Q5/RdSVqw5TEtA4Z+hsDd4SXNqcMmqspQ5/R+RXJIMzzNZ3z+METxUXRH9StFMspHMMT+4S3HWlKsRrqHhNDFSSXx4r6s6rMQvNDFSSWI4rYt5NIHhmRMcVNMK26QRtxQxN5+qnNNUTisAMqt4ASF7SAxFSrmKS++7N5ZhzqVcVZM4Ea+7N5ZSV1Ne0tQRrMHhmREU43N3zaFGsGdRN4MKsRHWNSs3maVRN/4SVKIMzzNM+z+METxUX3N5TisWsZMcAZEUAKHUTCsWmaQ3z6CDXxNDnTNZSrxxN)EWVRH6Nis6t+ZA5DV62NNWNE1cS1w4t6d6SAIxAtt6BaERs)s6zqsSrEMZ+qQAA5V5nNVqAns5t1wM3T1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFK4tFMsAHMMT+4S3HWlKsRrqHhNDx5nNNUTisAMqt4AGt741Ne0YNxMz+METxUX3N5TisWsZMcAZE5b344EKs6t+FRtCN4SXNDnTNZSrxxN)EWVRH6Nis6t+ZAA5dhzq4ZNSMxV7QMz6CDAWNDnaFGsGdRN4MKsRHWNSsSXxQ6s)ZSVNwAtE43t1wMMT1xAWI4rYt5NIHhmRMcVNMK2CtA4ZERNDx5bDFebtFMspHMMT+4S3HWlKsRrqHhNDx5nKNWNis5NeQvt54SV3w5TZM4S1w4twd6SAIxAtt6BaERs)s6zqsSrEQqmqHhN5QhADMStrMZQqQhmTF7SxNDnTNZSrx45RmvSq4Z2Ys3NxCDN5+SV1NR/R1RryFRNU+4SNVqATsAMa+hsDHSV1NR/R1RryFRNU+4SNVcV/sKtIZUN4MDXRs7ctFMsV1MV6d621wAtmsRtIQvNDx5nq4ZN/F3QotMV6d621wAVeQDEaxFbD4SV1Ne0t1RtbmhV4mx4qNWNnFSSrxMr)m4XDNUTZsUrbxMStQx4ANYSrmKS+49bDQqnNVcV/sKtbxMS6NMNWNKJaZ5trxvN/xAVqsStn1RrMERs)4Ur1NRzhFGs+dRmDMqnqw54tFZsqQ7mD4SVWI4BKsRtxQYpRdSVNw54tF4VaxFb)MD41xxAt1cX+dRV)4Y01xxAtZAS+QqETxWs3MSr6sWmaFRV4mvARH54tFxrItvV)Zv21wWXSs6rqMcAZEUJPHANG1RrrxM3Rs6X3VStZmKS+FRV5MR5PN5XtFZsqQ7mD4SVWI4rM1RtKZUN)EWV1NRznMxBqMqnDQv21VctotWsqHhNFVU4qN3zzFU4+FRV4mvAqN3zz4S3z+MnU+4Sq4ZmRs6rMFRsDsAV1NRzhFGs2NRV4MqNqVW2otAS1wvrSxWV3MGNttAMqQFbDdASWI4BosRrIMcA5Q70KV34tmKS+sMzZQv21wAtZQKtIH7mRQqb1NRzhFGs2HSAtF7SJt4re1cXIHhERmvARHW2Ts3NGdRN4Z4SXx4retWtKQ3rDN4SWI4BKs6rqZ9b)xWs1NR/R1RryFRNU+4Sq4ZmRs3N2xvNZEUX3N5TZF3QoxvmRdhzNIZXM1RtNxMETxWVqH6NE1Rr+VRt54U0K44ERF5t1wvmRmv2NN5caFGsIMRNZE6JPVRNEMZQqFRNDd4SXNK4TNZSrxvN4VWsDN5AtsAEaQ45RMDrqNWNSF3QoxFpRE6ARIMzaFGsIMRNZEWs344Vrs3N2EebDEhARshNZF3siVeb)d3bqN7AtsAMqVRt5s62RsGXE1RrI+vtFs6XNxMzzNxMz+METxWVqH6NEsKsZQvV4VU4DNAreMMNVxMS6d6SAIxAtsAMqVRt5HhzKV3TZM4Ea+vs4mMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMSretWsKMqz6CRAAIFSrmKS+ERN)s5nRVcVnQcMqtvtF47AqHWmKF3QoFqV6d621VqTZsAEawRsDZhAqsSrEM4XI4UN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DNUVeFWS1wMSvERSAIxAtsWtZHvtFEhzK44+os3NGH7NtF7SWx3XMmqspQ5/RZSN3MK2rsRtINRs2EUX3N5TZF3Qox4A5MRSqN3zaFGsI4UNZEUARs3T6sq5atFb)4WV1Ne0rmqspQ5/RZSN3MK2rsRtINRs2E5bN4xctFMQP+MV6d621VqTMtAEa49bDQqn3H55zF3Qod3Svd6SAIxAtsWtZHvtFMRXK+K2YsRBzxMStQxTX4DnTNZSrxvmDMRSDMSVeQDEa+7N5ZSV1Ne0tMMNZHvNUFh21VqTMtAEa49bDQqnNVqATsWS1w4tvZvSAIxAtsWtZHvtFMRXK+K2CM44bxMS61DAWNDnaFGQqHFb)x62qN3zzsWs2QAA5Zv21VRNZF3siVeb)d3bqN7AtsWQqZ9b)dhA1NR/R1RryFRNU+4SqVKNEM4MqMRsSF7SqVqAaMMNVQ5/RsAVDMStT1R+eZ6N4V6lPsGVtFMsAHMMT+4S3MSt6sSJeHhV44Y0DNW4tF4Sn1MSU1xAWI4roMMNxZAA4MR5PN6XE1cS1wMVwmSNWNDnaFGQaFebGEUARs3T6sq5atFb)4WV1Ne0rmqspQ5/RE5pP+K2rsRtINRs2EUMPs3TZF3QoN5V6d621wWXiQc4xCqz6CDAWNDnaF7BeHhV44Y0DNUVosA4VxMStxWV3MhVTFSSrx4AFQcVqsGXEsUr+dDNUF7SWxGVrmqspQ5z/4SXqHWNrs3NedDN4d4SXNqzTNZSrx4AFQcVqsGXEMZs2HvmTF7SAFq4TNZSrx4AFQcVqsGXEMZs2QvNUF7SxxFSrmKS+FRV5VAVNmZ2ntU41wMSwd6SAIxAtF6r2M3z6CDAWNDnaF7rZQhVGE62NMKlKQKS1wM46FhSAIxAtF6r2Mht5d74DNUTZsUrbxMStQMNAIFSrmKS+49bDQqn3VSrEMZs2HvmTF7SAFq4TNZSrxMr)m4XDNUTSsSX+HhN5QhA1Ne05NZ3z+METxAmPshVEt6BaERNUF7S1VKlRsAS1Q5z/MRXK+K2CM44ZHvt5sU43N6AtF4Snd3Svd6SAIxAtF6r2MhtF47ARHANEMZs2HvmTF7SAFq4TNZSrxMr)m4XDMStrsRrMZAAFEGV1Ne0yNZ3z+METxAmPshVEM4JeH7NZE6A3tMzzN4z9+MV6EG2WI4resRt1mYbFxU0KHA+osRrMw5z6H7s1VqA6Qc4ZN9bDZhz3NANEt6BaERNUF7S1VqAaQqN24AASFh21VqTZsAEaQYpR1cSXw5TSQRrVQ5/RZSVqMK2e1KsqZUN)EWVqN3zzFGsqQ6sDd5XJH5AFFSSrxvN4VWsDN5AtsAEaHxNFZhzqwWVtFxrItvV)Zv21VqTZsAEaQYpRs5nNVKNCs6tbxMS6FhSAIxAtsAMqVRt5m4SqMK2nMZsZw6N5VU41Ne0t1KQaQvQTFh21VqTZsAEaVDN4MDADN55K1R+eQvsDsAV1NR/R1RryFRNU+4Sq4ZmRs3NqQ6sDE3aPH5TrsSXqQSAtF7SAtFSrmKS+ERN)s5nRVcVnQcMqtvt5x6XNN5ctF4SnQ4tt1xAWI4BKs6rqZ6QRMRAK4ZNSsSJeCebD4SV1Ne054G3z+METxWVqH6NEsKsZQvV4VU4DMSretWsKMqz6CcNAIFSrmKS+ERN)s5nRVcVnQcMqtvtF47AqHWmKF3QotMV6d621VqTZsAEawRsDZhAqsSrEM4XI4UN4Z4SXx4rTt5NZFRNUFh21VqTMtAEa+vsDZ3sRmZ2Y1Rt9xMStQMNXIFSrmKS+Eqr)45nN44Vn1qNeZUN)MRS1Ne0YF4QKHMMT+4SqVSVTsSJeHhV44Y0DNUVosA4VxMStxAS3MGNT1qNVxMETxWVJHANEM44ZQFb5Q3nNVqATsWS1wM46FhSAIxAtsWtZHvtFEhzK44+osSXx+vmTF7SxNKVTNZSrxvmDMRSDMSVeQDEa+YbDmSSXNKMzNZ3z+METxWVJHANEF6r2Mht5+Rz3xMzzmc/c1MMT1xAWI4BKF6rMZ5r)m4XDNUVosA4VxMStxAS3MGNT1qNVxMETxWVJHANEF6r2MhtFx6X3VDctFMsAFqV6d621VqTMtAEa49bDQqnNMGJKF3Qod3SvFhSAIxAts6rMQYpRdSV1NR/R1RryFRNU+4SqVqctFZsqQ7mD4SVWI4BRsWmaQ7mDd4SXVRNetWtxMqETxWsqVW2rs6BqM5z6HGQPHUTCs5trxvmRV5nNNANeMM5aERN)dhXJN3zzNxMz+METxU0NNAtEM44ZQFb5Q3aPN3zzmcz945V6d621VK2C1DEa+vsDZ3sRmZ2tF3Qo+3SvERSAIxAttAXxNRtFEhzK44+osSX+Q7mRd4SXNDnTNZSrxxNF43sDMGXiQc4xCRtFx6XK4MctFMQPHMMT+4SN44Vn1qN9xMS6d6SAIxAtM44ZQFb5Q3n3HWlKs5t1wMz/4SV3HWVYQRtpxMETx5bKNWNZMM5aVc5REUX1Ne0YF4zpHMMT+4SNMhVZs6+eZ6s4E62qIMzzN43z+METx5bKNWNZMM5atFb)4WV1Ne0CNxMz+METx5bKNWNZMM5atFbDZSV1Ne05mqspQ5z/4SXqHWNrsSXIdqz6CcNAIFSrmKS+49bDM4SXNDnTNZSrxMr)m4XDNUTSs3NIQMz6CeSWNDnaF7rZQhVGE62NMK2as6rqQMz6CDXxNDnTNZSrxMr)m4XDNUTSsSX+Q7mRd4SXNq4CmqspQ5z/MRXK+K2aM4Eatvs)Qe0KIMzz43spHMMT+4SJH5AFs3NGdRN4Z4SXx4rCM44ZHMzt+4SJH5AFsSXx+vs)45nqwArot5t1wMVwVFSAIFSrmKS+49bDQqnNMGXitAEatFb)4WV1Ne0GmqspQ5z/MRXK+K2CM44ZHvtF47AqIMzzN4zpHMMT+4SJH5AFsSXx+vs)45nK4xttFMQc1MMT1xAEN7At1cX+dRV)4Y0RHAN/F3sitq/RmMsK44V51RtIH7N545n3HWlKs5t1wM/Rmv2KN5AMMx41Q5/RZSVqMK2e1KQPxM3Rs6X3VStZmKS+ERN)s5aPHABRs3NGdRN4Z4SXx4BRtA4Z+M/DMRXKtMzaFGsIMRNZE6JPVRNEtWQaQvs)sAN1NR/R1RryFRNU+4Sq4ZmRs3N2xvNZEU4qsStZQKS1wM4S1xAWI4BKs6rqZ9b)xWsDM3TSsRrKw6NDFSSXx4rYsRtxFqzt+4Sq4ZmRs3NqQ6sDE3aPH5TeMZtIHhERZ4SXVRNetWtxMqETxWVqH6NEsWsyHSA2E6XqVGXEQKs2tMz6CqbWNDnaFGsIMRNZEUbRs3Tns6t+Z9pRmMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMGJo1RtxMqz6CDAWNDnaFGsIMRNZEUbRs3Tns6t+ZA5RmvSqN5ctFMsb+MV6d621VqTZsAEawRsDZhAqsSrEM4JeMRN)d4SXNq4TNZSrxvN4VWsDN6ziQKtIMcAZE5bKVSVas5t1wMz/4hz3VqctmKS+Eqr)45nN44Vn1qNeZUN)mFS1NefzFM+z+METxWVJHANEM44ZQFb5Q3n3HAVTF3Qo+3SvERSAIxAtsWtZHvtFEhzK44+os3NGdRN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DMSretWsbxMS6d6SAIxAtsWtZHvtFEhzK44+osSXx+vmTF7SxNDnTNZSrxvmDMRSDMSVeQDEa+YbDmSSXNKMzNZ3z+METxWVJHANEF6r2Mht5+Rz3xMzzmc/c1MMT1xAWI4BKF6rMZ5r)m4XDNUVosA4VxMStx5bRHANZFSSrxvmDMRSDMSVeQDEatFb)4WV1Ne0CNxMz+METxWVJHANEF6r2MhtF47AqIMzz43spHMMT+4SqHANe1KsyMqz6HhANwWNZmKS+VRNUF7SqVqAaMMNVQ5/RsAVDN5AaQKS1wvmRmv2NN5caFGsqMRtFESVqH62tFZsqQ7mD4SVWI4BRsWmaFDmRmxADN5TZtA4245z6CqbWNDnaFGQaFebGEUARs3T6sq5aQ3z6CDXX4KVTNZSrxxNF43sDMGXiQc4xCRt5FSSXxv5zFM+z+METxU0NNAtEM44ZQFb5Q3nNVqATsWS1wMMT1xAWI4roMMNxZAA4MR5PN6XEMZs2QvNUF7SxxFSrmKS++vsDZ3sRIMzzF4QKHMMT+4SN44Vn1qNeZUN)EWVqN3zzFGQqQ5rD4h/PH9StmKS+FRV5VAVNmZlRMZQa+3z6CDXXx7nTNZSrx4AFQcVqsGXEscMaQ6mTF7SAxFSrmKS+FRV5VAVNmZ2S1RrMEqz6CqbAtFSrmKS+FRV5VAVNmZ2S1RtIMqz6CqNWNDnaF7rxMhN)VUADM3ToF3Qo45MT1xAWI4rM1RtNxMS6d6SAIxAtF6r2Mht5d74DN5TnF3Qo1MV6d621wAVeQDEaQAAZE62qH6NnF3Qo+St6d6SAIxAtF6r2Mht5d74DMSretWsbxMS6NMbWNDnaF7rZQhVGE62NMK2SsRrKCRETF7SxNDnTNZSrxMr)m4XDNUVosA4VxMStxU0NVGXoMMNZQvNUFh21wAVeQDEaFcA4MRSDN6NSt5NnxMStQxTX4DnTNZSrxMr)m4XDMStrsRrMZA5RmvSqIMzzNMbAHMMT+4SJH5AFsSXx+vs)45nNMGJKF3Qod3MT1xAWI4rM1RtKZAAFEhz3MK2ntU41wM4wm7AWNKJamKS+Vc5RVAVNM3TetWsIH7mRM4SXw62t1RrxQvsDs6XK44VotAEa+7N5ZSV1Ne0t1RryMYbDMqb1xxAtsAMqVRt5m4SqxMzzsWs2QAA5Zv21VqTZsAEaQYpRs5n3HWlKs5t1wM/Rs62Rs7n9F6r2M3zt+4Sq4ZmRs3N2xvNZE6S3M3TisUBKxMS/Z74KH5caFGsIMRNZE6JPVRNEMZQqFRNDd4SXNq4TNZSrxvN4VWsDN5AtsAEaQ45RMDrqNWNSF3QoxxN)MqbNtMzaFGsIMRNZEWs344Vrs3N2EebDEhARshNZF3siVeb)d3bqN7AtsAMqVRt5s62RsGXE1RrI+vtFs6XNxMzzNxMz+METxWVqH6NEsKsZQvV4VU4DNAreMMNVxMS6d6SAIxAtsAMqVRt5HhzKV3TZM4Ea+vs4mMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMSretWsKMqz6CRAAIFSrmKS+ERN)s5nRVcVnQcMqtvtF47AqHWmKF3QoFqV6d621VqTZsAEawRsDZhAqsSrEM4XI4UN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DNUVeFWS1wMSvERSAIxAtsWtZHvtFEhzK44+os3NGH7NtF7SWx3XMmqspQ5/RZSN3MK2rsRtINRs2EUX3N5TZF3Qox4A5MRSqN3zaFGsI4UNZEUARs3T6sq5atFb)4WV1Ne0rmqspQ5/RZSN3MK2rsRtINRs2E5bN4xctFMQP+MV6d621VqTMtAEa49bDQqn3H55zF3Qod3Svd6SAIxAtsWtZHvtFMRXK+K2YsRBzxMStQxTX4DnTNZSrxvmDMRSDMSVeQDEa+7N5ZSV1Ne0tMMNZHvNUFh21VqTMtAEa49bDQqnNVqATsWS1wM4CNvSAIxAtsWtZHvtFMRXK+K2CM44bxMS61DAWNDnaFGQqHFb)x62qN3zzsWs2QAA5Zv21VRNZF3siVeb)d3bqN7AtsWQqZ9b)dhA1NR/R1RryFRNU+4SqVKNEM4MqMRsSF7SqVqAaMMNVQ5/RsAVDMStT1R+eZ6N4V6lPsGVtFMsAHMMT+4S3MSt6sSJeHhV44Y0DNW4tF4Sn1MSU1xAWI4roMMNxZAA4MR5PN6XE1cS1wMSvERSAIxAttAXxNRtFEhzK44+osSX+Q7mRd4SXNDnTNZSrxxNF43sDMGXiQc4xCRtFx6XK4MctFMQPHMMT+4SN44Vn1qN9xMS6d6SAIxAtM44ZQFb5Q3n3HWlKs5t1wM/R47VNM3Tot5t1Q5z/4SXqHWNrs3NqtxN5Q4SXxvAMNZ3z+METx5bKNWNZMM5aCDN5dGV1Ne0SmqspQ5z/4SXqHWNrsSX+Q7mRd4SXNDnTNZSrx4AFQcVqsGXEMZs2QvNUF7SxxFSrmKS+FRV5VAVNmZ2ntU41wMSwd6SAIxAtF6r2M3z6CDAWNDnaF7rZQhVGE62NMKlKQKS1wM3T1xAWI4rM1RtKZUmDx5n34ZmRQKS1wMVw1DAWNDnaF7rZQhVGE62NMK2S1RrMEqz6CqbAtFSrmKS+49bDQqn3VSrEMZsZw6QDd4SXNebrmqspQ5z/MRXK+K2Yt5NIMqz6CcS3MGXrtAXxHhV4Z4SWI4rM1RtKZAAFEhz3MKlRMZQa+3z6CDXAx3XrmqspQ5z/MRXK+K2CM44ZHvtFx6X3VDctFMsAFqV6d621wAVeQDEaFcA4MRSDMStrsWS1wM4wd6SAIxAtF6r2MhtF47ARHANEQc47xMS6VFSAIFSrZ5trxxN)mvSKH5AaFS42Q3z6H7s1VqA6Qc4ZN9bDZhz3NANEt6BaERNUF7S1VRXiQKtIQYpRdSV14Z2TtW+KxMETxWVqH6NE1Rr+Vqz6HhANwWNZmKS+ERN)s5aPHABRs3NGdRN4Z4SXx4BRtA4Z+M/DMRXKtMzaFGsIMRNZE6JPVRNEtWQaQvs)sAN1NRznMxBqMqETxWVqH6NE1Rr+VRtFxAVNNWNnF3Qo+qV6d621VqTZsAEaQYpRs5nKVSris5NKMcAtF7S1VDViM4XAxMETxWVqH6NEsWsyHSA2E6Xq4MArQc4ZN6NUF7SqVqAaMMNVQ5/RZSVqMKlRtA4Z+vt5mZVNmZ251Rt1xMS6NvSAIxAtsAMqVRt5HhzKV3TZM4EaxFbD4SV1Ne0rmqspQ5/RZSVqMK2PsRtIQvNDx5nN4vXeMMNVxMS6d6SAIxAtsAMqVRt5HhzKV3TZM4EatFb)4UrqN3zz4SspHMMT+4Sq4ZmRs3NiHhEDZSVNMK2CM4MqMRmTF7SAtFSrmKS+ERN)s5nRVcVnQcMqtvtF4hAJHUTZF3Qox4A5MRSqN3zaFGsI4UNZEUARs3T6sq5a+YbDmSSXNqXMmqspQ5/RZSN3MK2rsRtINRs2EUXRH9StF4Sn1MSU1xAWI4BKF6rMZAA4MR5PN6XEt6BaERNUF7S1wAtitWsVxMETxWVJHANEM44ZQFb5Q3nNVqATsWS1wMMT1xAWI4BKF6rMZAA4MR5PN6XEM4JeEqz6CqNAIFSrmKS+Eqr)45nJH5AFs3NGQ3BTF7SAx3XrmqspQ5/RZSN3MK2M1RtKZUN)MRS1Ne0YN4z9+MV6d621VqTMtAEa49bDQqn3HWlKs5t1wMz/4hz3VqctmKS+Eqr)45nJH5AFsSX+Q7mRd4SXNq4CmqspQ5/RZSN3MK2M1RtKZAAFEGV1Ne05NZ3z+METxAV3VqAttA4VxM3Rs6X3VStZmKS+VRNUF7SqVqAaMMNVQ5/RsAVDN5AaQKS1wvEDxUVqN7AtsWQqZAA4VAVRtMzzQKt++RNU+4SqVKNEMMNMQSA2EWVqHUTeF5t1wM4S1xAWI4roMMNxZAA4MR5PN6XE1qt1wMVwmSNWNDnaFGQaFebGEUARs3T6sq5axMz6CDXX4KVTNZSrxxNF43sDMGXiQc4xCRtFx6X3VDctFMQc+qV6d621VK2C1DEa+vsDZ3sRmZ2S1RtIMqz6CqNWNDnaF7BeHhV44Y01Ne0rmqspQ5z/EhzK44+os3NGdRN4Z4SXx4r6QRtxQxN5Q4SWI4rCQqmqMcA2EWsNVK2YF3Qo+3Swd6SAIxAtM4XKMRNDE3nR4Z2asWS1w4+T1xAWI4rCQqmqMcA2EUMPHAmKF3QoFq4S1xAWI4rCQqmqMcA2EUMPs3TZF3QoQMV6d621wAtFs6Bq+vtFZ701Ne0MNZ3z+METxAmPsSAtFMspHMMT+4SJH5AFs3Nytvt5ZhA1Ne05mqspQ5z/MRXK+K2aM4EaQ6N)s6A1Ne0rmqspQ5z/MRXK+K2aM4EatFb)4WV1Ne0CNxMz+METxAmPshVEtWt+ZA5RMDrRV7ctFMspHMMT+4SJH5AFs3NGdRN4Z4SXx4roMZ+edcA5MRAqN3zaF7rZQhVGE5bN44VTs3NqtxN5Q4SXxvAyNMQPHMMT+4SJH5AFsSXx+vs)45nNVqATsWS1wM4CNvSAIxAtF6r2MhtF47ARHANEM4JeEqz6CDTxxFSrmKS+49bDQqnNMGXitAEaQxNSF7SAx3XrmqQeE5ETxU4KHANTsRrMw5z6H7s1VqA6Qc4ZN9bDZhz3NANEt6BaERNUF7S1VRXiQKtIQYpRdSV14Z2TtW+KxMETxWVqH6NE1Rr+Vqz6HGQPHUTCs5trxvN4VWsDN5AtsAEa+7N5ZSV1Ne0tsWsyHS5TESmPsSAtmKS+ERN)s5aPHABRs3NMdRV4MKsJN3zzQKt++RNU+4Sq4ZmRs3N2xvNZEU4qsStZQKS1wM4t1xAWI4BKs6rqZ9b)xWsDM3TSsRrKw6NDFSSXx4rttAXICqzt+4Sq4ZmRs3NqQ6sDE3aPH5TeMZtIHhERZ4SXVRNetWtxMqETxWVqH6NEsWsyHSA2E6XqVGXEQKs2tMz6CqbWNDnaFGsIMRNZEUbRs3Tns6t+Z9pRmMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMGJo1RtxMqz6CDAWNDnaFGsIMRNZEUbRs3Tns6t+ZA5RmvSqN5ctFMsb+MV6d621VqTZsAEawRsDZhAqsSrEM4JeMRN)d4SXNq4TNZSrxvN4VWsDN6ziQKtIMcAZE5bKVSVas5t1wMz/4hz3VqctmKS+Eqr)45nN44Vn1qNeZUN)mFS1NefzFM+z+METxWVJHANEM44ZQFb5Q3n3HAVTF3Qo+3SvERSAIxAtsWtZHvtFEhzK44+os3NGdRN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DMSretWsbxMS6d6SAIxAtsWtZHvtFEhzK44+osSXx+vmTF7SxNDnTNZSrxvmDMRSDMSVeQDEa+YbDmSSXNKMzNZ3z+METxWVJHANEF6r2Mht5+Rz3xMzzmc/c1MMT1xAWI4BKF6rMZ5r)m4XDNUVosA4VxMStx5bRHANZFSSrxvmDMRSDMSVeQDEatFb)4WV1Ne0n43+z+METxWVJHANEF6r2MhtF47AqIMzz43spHMMT+4SqHANe1KsyMqz6HGQPHUTCs5trxvmRZ4SXVRNetWtxMqETxWsqVW2etWtbxM3Rs6X3VStZmKS+VRmqEUAqHWNmF3siQ4A/VAVWI4BRsWmaFDmRmxADN5TZtA4245z6CRAWNDnaFGQaFebGEUARs3T6sq5aQ3z6CDXX4KVTNZSrxxNF43sDMGXiQc4xCRt5FSSXxv5zFM+z+METxU0NNAtEM44ZQFb5Q3nNVqATsWS1wMMT1xAWI4roMMNxZAA4MR5PN6XEMZs2QvNUF7SxxFSrmKS++vsDZ3sRIMzzF4QKHMMT+4SN44Vn1qNeZUN)EWVqN3zzF7Bq+Mzt+4SNMhVZs6+eZ6N/xU03N3zzmc/K+MV6d621wAtFs6Bq+vt5Q7034xctFMs1HMMT+4SNMhVZs6+eZA5RmvSqIMzzNMbAHMMT+4SNMhVZs6+eZA5RmvAqN3zz4S3z+METx5bKNWNZMM5aQxNSF7SXx7nTNZSrxMr)m4X1Ne0rmqspQ5z/MRXK+K2aM4EaERETF7SAxFSrmKS+49bDQqn3VSrEtAMqVRETF7SWxYbrmqspQ5z/MRXK+K2aM4EatFb)4WV1Ne0SN43z+METxAmPshVEtWt+ZA5RMDrRV7ctFMQP+MV6d621wAVeQDEa+7N5ZSV1Ne0tMMNZERNDQRXJs34tmKS+49bDQqnNMGXitAEaVc5REUX1Ne0YN4z9+MV6d621wAVeQDEaFcA4MRSDMSretWsbxMS6d6SAIxAtF6r2MhtF47ARHANEM4JeEqz6CDTWNDnaF7rZQhVGE5bN44VTsSXIdqz6CDTX4DnTNZtnQ5z/4hXqVqc9scMqQhmTF7SJt4re1cXIHhERmvARHW2Ts3NGdRN4Z4SXx4retWtKQ3rDN4SWI4BKs6rqZ9b)xWs1NR/R1RryFRNU+4Sq4ZmRs3N2xvNZEUX3N5TZF3QoxvmRdhzNIZXM1RtNxMETxWVqH6NE1Rr+VRt54U0K44ERF5t1wvEDxUVqN7AtsAMqVRt5m4SqMK2Ss6txMRETF7SAtFSrmKS+ERN)s5aPHABRsSXItvs)QDrqs3ztF4S++hsD43b1xxAtsAMqVRt5s62RsGXE1RrIQS5DZhzKVqctFZsqQ7mD4SVWI4BKs6rqZ6mRdhzNmZ2esW+eZ6ERmx41Ne0CmqspQ5/RZSVqMK2PsRtIQvNDx5aPVqACs5t1wMMT1xAWI4BKs6rqZ6QRMRAK4ZNSsSJeCebD4SV1Ne0rmqspQ5/RZSVqMK2PsRtIQvNDx5nNVqATs5NVxMS6dxAWNDnaFGsIMRNZEUbRs3Tns6t+ZAAFESVqHUctFMsAHMMT+4Sq4ZmRs3NiHhEDZSVNMK2CQKtZQ6NUF7S1wAtitWsVxMETxWVJHANEM44ZQFb5Q3n3H55zF3Qo1MSU1xAWI4BKF6rMZAA4MR5PN6XEt6rZHMz6CDXX4KVTNZSrxvmDMRSDMGXiQc4xCRt5+D0q4MctF4S+FRs)4AV1xxAtsWtZHvtFEhzK44+osSX+Q7mRd4SXNDnTNZSrxvmDMRSDMGXiQc4xCRtF47AqIMzz43spHMMT+4SqVSVTsSXZQhVGEUJPs3XtFMQc1MMT1xAWI4BKF6rMZ5r)m4XDNUVitAS1wMVwVFSAIFSrmKS+Eqr)45nJH5AFs3NGdRN4Z4SXx4rCsRrMMqzt+4SqVSVTsSXZQhVGEUMPHAmKF3QoFq4S1xAWI4BKF6rMZ5r)m4XDMStrsWS1w4t6d6SAIxAts6rMQYpRdSV1NRznMxBqMqETxWsqN3zzsWs2QAA5Zv21VRNZs3N2Q6ETF7SqVqAaMMNVQ5/RsAVDMGXZs6raxM3Rs6X3VStZmKS+VRmqE5b3VqArs3NIMDN4m4N1Ne0CmqspQ5/RE5pP+K2rsRtINRs2E6X1Ne0YF4QKHMMT+4S3MSt6sSJeHhV44Y0DN5ztF4Sn1MSU1xAWI4roMMNxZAA4MR5PN6XEMZs2HvmTF7SAIFSrmKS+dcA543nN44Vn1qNeZA5RmvAqN3zz4S3z+METxUARs3T6sKS1wMMT1xAWI4rrsRtINRs2EUX3N5TZF3QoxvN)dSNNNAVetAS1Q5z/4SXqHWNrs3NqtxN5Q4SXxvAMNZ3z+METx5bKNWNZMM5aCDN5dGV1Ne0SmqspQ5z/4SXqHWNrsSX+Q7mRd4SXNq4CmqspQ5z/4SXqHWNrsSX+QhV4Z4SXNebTNZSrx4AFQcVqsGXEQc47xMS6EDAWNDnaF7rZQhVSF7SAIFSrmKS+49bDQqn3VSrEsWtbxMS61RSAIxAtF6r2Mht5d74DNUTZsUrbxMS6d6SAIxAtF6r2Mht5d74DMSretWsbxMS6NMbWNDnaF7rZQhVGE62NMK2SsRrKCRETF7SAIFSrmKS+49bDQqn3HWlKs5t1wMz/4SXqHWNrFSSrxMr)m4XDMStrsRrMZ6N/xU03N3zzmc/c1MMT1xAWI4rM1RtKZAAFEhz3MK2S1RrMEqz6CqbAtFSrmKS+49bDQqnNMGXitAEaFcA4d4SXNq4rmqspQ5z/MRXK+K2CM44ZHvtFZ701Ne0yF4spHMMDQv21wAtatAXKH7mRM4SXw62t1RrxQvsDs6XK44VotAEa+7N5ZSV1Ne0t1RryMYbDMqb1xxAtsAMqVRt5m4SqxMzzsWs2QAA5Zv21VqTZsAEaQYpRs5n3HWlKs5t1wMz/x6X3VqTot5+e49bDM4SWI4BKs6rqZ9b)xWsDNANoQc4ZVqrUF7SKVSrGs5trxvN4VWsDN5AtsAEatvND4SVKIMzzNxMz+METxWVqH6NE1Rr+VRtFZ74RH6V/s6t1xMStxAS3M3)oFSSrxvN4VWsDN6NasR+eZ9b)ZhXNV3TiQKsVxM3Rs6X3VStZmKS+ERN)s5nqVDTiMM5aQhmDE3nKVqASF3QoFqV6d621VqTZsAEawRsDZhAqsSrE1Ks2FRNUF7SAIFSrmKS+ERN)s5nRVcVnQcMqtvtFEYfPsStZF3Qo+MV6d621VqTZsAEawRsDZhAqsSrEMZs2HvN5Z4SXNDcrmqspQ5/RZSVqMK2PsRtIQvNDx5nNMGXZs6rbxMS6NvSAIxAtsAMqVRt5HhzKV3TZM4EaFREDMR2qN3zzF7rxH7mRZ4SWI4BKF6rMZAA4MR5PN6XEt6r21Mz6CeSXNYSrmKS+Eqr)45nN44Vn1qNeZUN)MRS1Ne0YF4QKHMMT+4SqVSVTsSJeHhV44Y0DNUVosA4VxMStx5bRHANZFSSrxvmDMRSDMGXiQc4xCRtFx6X3VDctFMspHMMT+4SqVSVTsSJeHhV44Y0DMStrsWS1w4t6d6SAIxAtsWtZHvtFMRXK+K2Y1Rt9xMS6VFSAIFSrmKS+Eqr)45nJH5AFs3NGH7NtF7SWxGMzNZ3z+METxWVJHANEF6r2Mht5+D0q4MctF4S+FRs)4AV1xxAtsWtZHvtFMRXK+K2S1RrMEqz6CqbAtFSrmKS+Eqr)45nJH5AFsSXx+vmTF7SxNDnTNZSrxvN)46JPVDTZF3siVeb)d3bqN7AtsWsVxM3Rs6X3VStZmKS+VRmqE6X3V7ctFxrItvV)Zv21VRNZsSJeMRN)QASXw5TSQRrVQ5/RsAVDMStT1R+eZ6N4V6lPsGVtFMQcQMV6d621VK2C1DEa+vsDZ3sRmZ2eF3Qo+3SvERSAIxAttAXxNRtFEhzK44+os3N1xMStQFSXNYSrmKS+dcA543nN44Vn1qNeZA5RmvSqIMzzNZ3z+METxU0NNAtEM44ZQFb5Q3nNVqAns5t1w4tt1xAWI4rrsRtINRQTF7SX4KVTNZSrx4A4MR5PN6XEt6BaERNUF7S1VKlRsAS1Q5z/4SXqHWNrs3NqtxN5Q4SXxvAMNZ3z+METx5bKNWNZMM5aCDN5dGV1Ne0SmqspQ5z/4SXqHWNrsSX+Q7mRd4SXNq4CmqspQ5z/4SXqHWNrsSX+QhV4Z4SXNebTNZSrx4AFQcVqsGXEQc47xMS6EDAWNDnaF7rZQhVSF7SAIFSrmKS+49bDQqn3VSrEsWtbxMS6VxTWNDnaF7rZQhVGE62NMK2as6rqQMz6CDXxxG4TNZSrxMr)m4XDNUTSsSX+Q7mRd4SXNebrmqspQ5z/MRXK+K2aM4Eatvs)Qe0KIMzz4SspHMMT+4SJH5AFs3NGdRN4Z4SXx4rosWQPxMETxAmPshVEM4JeH7NZEWsNVK2YF3Qo+34wm7AWNDnaF7rZQhVGE5bN44VTsSX+Q7mRd4SXNebrmqspQ5z/MRXK+K2CM44ZHvtF47AqIMzzN4zpHMMT+4SJH5AFsSXx+vs)45nK4xttFMQc1MMT1xAEN7AtMMNMMeb)+hz3VcAtFxraxFb)4hARshNeQc4ZdDNZEUX3N5TZF3QoxFb)dSJPsSVCFSSrxvN4VWsDN5AtsAS1wvmRmv2NN5caFGsIMRNZE6JPVRNEt6BaERNUF7S1VRNasRtpm3r)m4X1xxAtsAMqVRt5m4SqMK2TtAXIHhN/EcSXVRNetWtxMqETxWVqH6NE1Rr+VRtFxAVNNWNnF3QoFqV6d621VqTZsAEaQYpRs5nKVSris5NKMcAtF7S1VDViM4XAxMETxWVqH6NEsWsyHSA2E6Xq4MArQc4ZN6NUF7SqVqAaMMNVQ5/RZSVqMKlRtA4Z+vt5mZVNmZ251Rt1xMS6NvSAIxAtsAMqVRt5HhzKV3TZM4EaxFbD4SV1Ne0rmqspQ5/RZSVqMK2PsRtIQvNDx5nN4vXeMMNVxMS6d6SAIxAtsAMqVRt5HhzKV3TZM4EatFb)4UrqN3zz4SspHMMT+4Sq4ZmRs3NiHhEDZSVNMK2CM4MqMRmTF7SAtFSrmKS+ERN)s5nRVcVnQcMqtvtF4hAJHUTZF3Qox4A5MRSqN3zaFGsI4UNZEUARs3T6sq5a+YbDmSSXNqXMmqspQ5/RZSN3MK2rsRtINRs2EUXRH9StF4Sn1MSU1xAWI4BKF6rMZAA4MR5PN6XEt6BaERNUF7S1wAtitWsVxMETxWVJHANEM44ZQFb5Q3nNVqATsWS1wMMT1xAWI4BKF6rMZAA4MR5PN6XEM4JeEqz6CqNAIFSrmKS+Eqr)45nJH5AFs3NGQ3BTF7SAx3XrmqspQ5/RZSN3MK2M1RtKZUN)MRS1Ne0YN4z9+MV6d621VqTMtAEa49bDQqn3HWlKs5t1wMz/4hz3VqctmKS+Eqr)45nJH5AFsSX+Q7mRd4SXNq4CmqspQ5/RZSN3MK2M1RtKZAAFEGV1Ne05NZ3z+METxAV3VqAttA4VxMS/Z74KH5caFGsqMqz6HGQPHUTCs5trxvmRV5aPHUTnF3siQ4A/VAVWI4BRsWma+vN)VA21NRznMxBqMqETxWsqVW2CtWs2+vt5ZSV34MAMF3QoFqV6d621VK2C1DEa+vsDZ3sRmZ2eF3Qo+3SvERSAIxAttAXxNRtFEhzK44+os3N1xMStQFSXNYSrmKS+dcA543nN44Vn1qNeZA5RmvSqIMzzNZ3z+METxU0NNAtEM44ZQFb5Q3nNVqAns5t1w4tt1xAWI4rrsRtINRQTF7SX4KVTNZSrx4A4MR5PN6XEt6BaERNUF7S1wAretWsIdDNUFh21wAtFs6Bq+vt5sU43N6AtF4Sn45MT1xAWI4rCQqmqMcA2E903NU)KF3QotMV6d621wAtFs6Bq+vtFx6X3VDctFMsb+MV6d621wAtFs6Bq+vtFx6XK4MctFMQPHMMT+4SNMhVZs6+eZ6V4tSSXNKVrmqspQ5z/MRXKtMzzNZ3z+METxAmPshVEtWt+Z6mDd4SXNqXTNZSrxMr)m4XDNUTSs3NyMRN/d4SXxvA5NZ3z+METxAmPshVEtWt+ZA5RmvSqIMzzNMbAHMMT+4SJH5AFs3NytvtFx6zqN6XnF3QoN5MT1xAWI4rM1RtKZUN)EWVqN3zzFGsqQ6sDdASWI4rM1RtKZAAFEhz3MKlRMZQa+3z6CDXAx3XrmqspQ5z/MRXK+K2CM44ZHvtFx6X3VDctFMsAFqV6d621wAVeQDEaFcA4MRSDMStrsWS1wM4wd6SAIxAtF6r2MhtF47ARHANEQc47xMS6VFSAIFSrZ5trx4AFZhX3VqTitWsNxMS/QA3PHAtnsRtqQhV4MD03MK2Yt5NIMqz6Cc3PHUTF1RtZFqzt+4Sq4ZmRs3N2xvNtF7SKVSrGs5trxvN4VWsDN5AtsAEa+7N5ZSV1Ne0tsWsyHS5TESmPsSAtmKS+ERN)s5aPHABRs3NMdRV4MKsJN3zzQKt++RNU+4Sq4ZmRs3N2xvNZEU4qsStZQKS1wM4U1xAWI4BKs6rqZ9b)xWsDM3TSsRrKw6NDFSSXx4rYsRtxFqzt+4Sq4ZmRs3NqQ6sDE3aPH5TeMZtIHhERZ4SXVRNetWtxMqETxWVqH6NEsWsyHSA2E6XqVGXEQKs2tMz6CqbWNDnaFGsIMRNZEUbRs3Tns6t+Z9pRmMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMGJo1RtxMqz6CDAWNDnaFGsIMRNZEUbRs3Tns6t+ZA5RmvSqN5ctFMsb+MV6d621VqTZsAEawRsDZhAqsSrEM4JeMRN)d4SXNq4TNZSrxvN4VWsDN6ziQKtIMcAZE5bKVSVas5t1wMz/4hz3VqctmKS+Eqr)45nN44Vn1qNeZUN)mFS1NefzFM+z+METxWVJHANEM44ZQFb5Q3n3HAVTF3Qo+3SvERSAIxAtsWtZHvtFEhzK44+os3NGdRN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DMSretWsbxMS6d6SAIxAtsWtZHvtFEhzK44+osSXx+vmTF7SxNDnTNZSrxvmDMRSDMSVeQDEa+YbDmSSXNKMzNZ3z+METxWVJHANEF6r2Mht5+Rz3xMzzmc/c1MMT1xAWI4BKF6rMZ5r)m4XDNUVosA4VxMStx5bRHANZFSSrxvmDMRSDMSVeQDEatFb)4WV1Ne0rmqspQ5/RZSN3MK2M1RtKZAAFEGV1Ne05NZ3z+METxAV3VqAttA4VxM3Rs6X3VStZmKS+VRNUF7SqVqAaMMNVQ5/RsAVDN5AaQKS1wvEDxUVqN7AtsWQqZAA4VAVRtMzzQKt++RNU+4SqVKNEMMNMQSA2EWVqHUTeF5t1wM4wdvSAIxAttAXxNRtFEhzK44+os3mcxMStQFSXNYSrmKS+dcA543nN44Vn1qNeZ9btF7SX4KVTNZSrxxNF43sDMGXiQc4xCRtFx6X3VDctFMspHMMT+4S3MSt6sSJeHhV44Y0DMSreQc4VxMS61RSAIxAtM44ZQFb5mSSXNqXMmqspQ5z/EhzK44+os3NGdRN4Z4SXx4BKtAXKHMzt+4SNMhVZs6+eZ6N/xU03N3zzmc/K+MV6d621wAtFs6Bq+vt5Q7034xctFMs1HMMT+4SNMhVZs6+eZA5RmvSqIMzzNZ3z+METx5bKNWNZMM5atFbDZSV1Ne05mqspQ5z/4SXqHWNrsSXIdqz6CcNAIFSrmKS+49bDM4SXNDnTNZSrxMr)m4XDNUTSs3NIQMz6CD4WNDnaF7rZQhVGE62NMK2as6rqQMz6CDXxNDnTNZSrxMr)m4XDNUTSsSX+Q7mRd4SXNq4rmqspQ5z/MRXK+K2aM4Eatvs)Qe0KIMzz43spHMMT+4SJH5AFs3NGdRN4Z4SXx4rosWQPxMETxAmPshVEM4JeH7NZEWsNVK2YF3Qo+34wm7AWNDnaF7rZQhVGE5bN44VTsSX+Q7mRd4SXNDnTNZSrxMr)m4XDMStrsRrMZAAFEGV1Ne0yNZ3z+METxAmPshVEM4JeH7NZE6A3tMzzN4z9+MV6EG2EN7AtM4XIQhV4V5nNNWNas6rxQxNFFSSXNebTNZtnQ5/RQcV3VKNS1RrrxMS/QA3PH6XCF3sitq/RmxVK4xttFxrItvV)Zv21VqAGQcMaZAAFZhXK4ZNCF3sit5z/4h23MhVitWsNxMETx5sNVK2G1qNeH7mRM4SWI4rCtWQqQhs5MRSqtMzaF7BzxvtU+43PshVrF3siVeb)d3bqN7At1RtK+vtF4h5Ps3TZMx41wvrSx5bK4MATsA4ZHvNSFh21VctStAJqNRs4MRSqtMzaF7rxHvN)m42RHAN/FSSrxMntx6VWI4BKs6r2wUN4Z4SXw5TSQRrVQ5/RZSEPH6VasWmaFRV4mvAqs34tF4Vax4AFZhX3VqTitWsNxMETx5b34Z2FsRrMw5zt+43PMSroQRrxCRs)4Ur1xxAtMMNMMeb)+hz3VcAtmKS+sMzZQv21wWXiM4XIdDmTF7SKVSrGs5trx4A4MqbK4Z2asSXxQFbDZSVNtMzzHU4+FRV4mvSq44VTsU41Q5z/xUV3VcNitWsNxMETx5b34Z2FsRrMw5zt+43PMSroQRrxCRs)4Ur1xxAtMMNMMeb)+hz3VcAtmKS+QhsDF3JPMSroQRrxCRs)4Ur1xxAtZAS+QqETx5pPNW2GQKS1wvEDxUVqN7AtMMNxdRVDZ3nNM3TeQcMqFqz6H7N1wAtn1RrMERs)4Ur1xxAtMMNydRV5MRSqtMzaFGsxtxNFV5sR44VTsU41Q5z/4hSqH5AmsRrMw5zt+4SEx4rKmKS+FRV5MR5PN5XtFxrItvV)Zv21w6VrtAEaFRN)+4SXNqzTNZtnQ5/RmvzN4ZNZsD41wMrSx5s3NUToM4S1wMzt4S4IERN4ZGEPFq4tFh21wAtFsRtINRQTF7SqVqAaMMNVQ5z/4SXRs3T6sq5aQxNGEA23VcERs5t1wvEDxUVqshAaFGs2HSAZEAVJVGXat5NZQMz6H7s1VctotAMatMz6CcS1QvN4ZGVq4M)KsA41xxAtM4XKHhV44Y01NR/R1RryFRNU+4SKVcVCQRr2Q6sDHhXK44VotAS1wvEDxUVqshAaFGs2NUN5MKVDNAre1qNYFRV4m4S1NRzhF7rxMhsDZ3sRIMzzQKt++RNDQv21VcrSs6r2M6t5d3s1NRzhFGs2NRV4MqmPs3TZF3QoxFb)dSJPsSVCFSSrxFb)ZGVRs3Tit5NMFRt54U0NVDVetWS1wvrSx6zqNANoMZsVmhNFxAV3Vq5Ks5t1Q5z/14SDN7At1qmaHvN4MRARHW2TMx41wvrSx5bK4MATsA4ZHvNSFh21wArGtWsMH7mRM4SWI4resRt1xMETx6XRs3z91cX+dRV)4Y0RHAN/FSSrxFbFxU0KHA+osRrMw5zt+4SNNANZ1RrYH7mRM4SWI4rCtAMaMhV5mv2RtMzaF7BzxvtU+4SqN5AYsWmaMRERV6SKV34tF4VaxvV5V6XN4Z2TFGtxMhsDZ3sRIMzaF7rKMebDE703xZXSs6rydeb)d4SWI4rcFSVnQ5/RQhzq4ZNEMMNedREDN4SXx4rtMZQqQhsSEhlPtMzaF7rxMDN4V5sKIMzzQKt++RNDQv21VRNSs6BqFRV4mvSq44VTsU41wMrSx5bK4MAnsRrAxM3Rs6X3VStZmKS+FRV5MR5PN5XtFZsqQ7mD4SVEN7AttAMqw6sDZ3aPHW4tFxraxvN)46JPVDTZsWS1wvEDxUVqN7Att6BaERNUF7S1VDTo1qN2Q5/Ds6zqsSAtZ5trxxN)mvSKH5AasSXZQhVSF7SJt4rt1RtxMqz6CcS34Z261RrrmhERMcVKtMzaFGsqdc5R4SVDMStn1RtIHYbSF7SKVSrGs5trxvs)45NqsSrns6t1xM3Rs6X3VStZmKS+FRN)dSEPM7ctF4S+ERsD4hJPVDTZsWS1Q5z/4h5Ps3Ti1D41wvEDxUVqshAaF7BetvND4SVKV34tFxraxxN4MqbKIMzzN43z+METx63PHUVZF3QoxxmRE6Sq4ZmRs6rMFRsDsAV1xxAtQc42x4ASF7S)FK4TNZSrtMV6d62AtFSrmcsbHMMT+xVWNDna4S3z+MVvMvSAIx5zmqspQ5z/14SDshAaF7rxQhmRV5nR4ZNesWS1wMrSx5bKNAVn1qN9xMS/Z74KHWmaZ6tnQ5/RMRSqVDttFxraxFb)xWsDNAVTsWS1wMrSx5s3NUTE1Ks2tMz6CcS1QvN4ZGVq4M)KsA41xxAt1qmaQ6t5x6XNNqztF4S1Nq)K1RAA4DcrZGEPxMETx5s3NUTEsRrIQ6NUF7S1xM4SdMs+IMMKxA4IxMzaFGsKQUNFM4SXw5TSQRrVQ5z/4Y03MhVEtA42xvN)+4SXw5TSQRrVQ5z/4Y03MhVEQc4Z+hNDFSSXVRNetWtxMqETx5bKNAVn1qN9xM3Rs6X3VStZZ5trxFb)ZGVRs3Tit5NMFqz6H7s1wArZt6BaN6mqE5bR4M5KtAXNxM3Rs6X3VStZmKS+tvN)+D0KVKNEQqmqQSA4E6S1NRznMxBqMqnU+43PMSroM4XxCeb)MD41NRzhFGsxdDN2EAJPshNZF3QoxMznsA4I4qT2Z3sAM3zt+4SqHANe1KsyMRmTF7SqVqAaMMNVQ5/RsU03wUctF4S+HxNFxUJPHUAtmKS+wUN4EAX1NRznMxBqMqETxUr34Z2Fs3NxdDN4EU41Ne0tF3pK+MSwEGSxQvN4FSSrxxmqE5s3NUTE1RrxNRN)46A1Ne0tFhA24xc6ZGSxERN4FSSrxxmqE5bR4Z2Fs3NIQMz6HhANwWNZmKS++htF4Y03MhVEsUrAxMS/Z74KH5caFGsGZAA5Q70K+KloMx41wvEDxUVqN7AttWmaFRs4EAXDMStn1RtIMqz6HhANwWNZmKS+HvNDQqnqVDTesAXxZ9b5E621Ne0tF3pPdSt6VMNAxhX2FSSrxxmRVAXDN6VS1RrIZ9b5E621Ne0tF3beE3SwQGXAQM4nFSSrxxmRVAXDMS+otAXIZ9b5E621Ne0tFhAq4M)KsA4IERN4FSSrxxmRVAXDMS+otAXKZAAFZhXK4MctFZsqQ7mD4SVWI4rTs6tKZAAFZhXK4ZNE1qmaQ5z6CcS1Feby43QcN54VsA41xxAttWQqMhtFZhzK4xTZs3NxdDmTF7S1x4t4ZGVx4M)c4GSxN3zaF7rxQMr)dSV1Ne0tt6BaERNDx6S1w6AaFGsx+cAFZ703VW2C1qma+vNUF7SJt4retWsZ+htF47AqHWmKF3Qo45V6d621VctotAMatvt5VWVqN5ctF4S1Nq)KsA4IERN4N4spxMETx5s3NUToM4Ea+Yb)MRS1Ne0tFhAq4M)KsA4INebFFSSrxvN4MqpPHArasWmaQ7mRMDJPs3Tit5mzxM3Rs6X3VStZmKS+MDmRm4S34ZmKF3siQ4A/VAVWI4r/1RtpxMS6VxAWNDnaFGsKQUNFM4SXw5TSQRrVQ5/RQR23MhVE1qmaQUNFFSSXxMz6ZGVq4M)KsA4ANK4tmKS+Q6N)4UrK4MXtFMQc14tS1xAEN7AtsAMqVRt5MRSqIMzzFU4+NDN5d70NxMzzFSSx4M)KsA4IERN4ZSS1Q5z/4SXRs3T6sKS1wvmRmv2NNWmamKS+CRsDZ7JPsSrms6t1xMS/QA3PNW2as3NeHhETF7S1xM4M43pKM3SwMxAAIMzaFGsxdDN2EA2RHUTaF3QoxMzCEcXXxSAM43bp+Mzt+43PNW2as3NGHSAFN4SXxMz6F4zN4AtCEcXA4DntmKS+EDmqE5s3NUTEsc4ZQMz6CcS1Q4r4dZVqIM)KsA41xxAtsA4GZ9b5E62DNUXitA4rxMStF3sbERmTZGV+4M)K1cSWI4BKtWmaMDmRm4S34ZmKF3siVeb)d3bqN7AtsW+qtFbDZhz3N9StFMsAHMMT+4SqHANe1KsyMRmTF7SKVSrGs5trxvNDQ7A34ZlKsWmaMRmRsAEPM7ctFxrItvV)Zv21wAtiFWsVxMS6F7VWNKJamKS+M6NDMcSRHAmKMxEa+RsUF7SJt4r6t5NyZ9b)43sqHANnF3QoxMznsA4bZMTvF4/K1Mzt+43PNW2as3N+w5z6CcS1FDnrN4sp+MMcdx41xxAt1qmaQ6t5xU0NVqTZM4S1wMztNxVI4Kmc43cbtM3TFh21Vctot55aQvNDQhA1Ne0tF3bbt4tvFhAAEcr4FSSrxvN)46JPVDTZsWS1wvEDxUVqN7AtsWQaHvETF7S1VcVTQcMqtMzt+4SNN6XoQDEaxvNSF7SKVSrGs6tnQ5/Rd3sDNAVTsWS1wMrSx5s3NUTE1Ks2Eqz6CcS1QvN4ZGVq4M)KsA41xxAt1qmaQ6t5s6XRHUTZsWS1wMzt4S4IERN4ZGVq4MTtFh21Vctot55awUN5d4SXxMz6ZGVqE3)cN4NXx3XtmKS+NDN5d3nqNW2osWS1wMzt4S4IEq5cdMpK453TFh21Vctot55aHhN4V6X3IMzzFSSx4M)KmZ4bFKVMFZS1Q5/R4703mZ2osD41wMzt4S4IERN4ZGVq4MTtFh21Vctot55aMhETF7S1x4t4ZGV2VxcCEcNXIMzaFGsKQUNFM4SXw5TSQRrVQ5z/4Y03MhVE1Ks2tMz6HhANwWNZmKS+FRs4EAXDNUTe1KQqQ5z6HGQPHUTCs5trx4A5Q70K+K2nsRrxMAASF7SqVqAaMMNVQ5z/4SXRs3T6sKS1wvEDxUVqN7AtQcMq1vV2E5QPsStZF3QoxvVDE7AqsSr61RtxMqz/Qv21VcNoQc4ZVqrUF7SJt4retWsZ+htF4hAJHUTZF3QoxFb5dhXNMSti1D41Q5/Rx62Ks3ztFZsqQ7mD4SVWI4r6t5NyZ9b)xWsDN6XiQKS1wMztNFSAFqXCF4sxIM4SFh21Vctot55aQYpRs5nR44VnsSXIMqBDd4SXxMz6ZGVq4M)KsA4bNDctmKS+NDN5d3aPHABRs3NGHSAFN4SXxMz6F4sA1M4Cm3bbNq4tmKS+NDN5d3aPHABRs3NGHSAF43nK4ZmzQKS1wMzt4S4IERN4ZGVqI4+TFh21Vctot55aQYb54SV3wUctF4S1NDqKxWSbEcBTZGEPxMETx5s3NUTE1KQatvN4VU41Ne0tF3b+4MMKdMbINcBcFSSrxFb5E62DN5ToMZsGQ7N/Z3nR44VnF3QoxMzCsWXIEebG4G4q4Mzt+43PNW2as3NIdc5R+RX3w5TEt6rZFcASF7S1x4t4Z3sNFctC4S4IxMzaFGsxdDN2EUr34MACMx41wMztNxAA4DnrN4spQM)TFh21Vctot55aCRsDd4SXxMz6ZGVq4M)KsA4bNDctmKS+NDN5d3nRVGNSQKS1wMzt4S4IERN4ZGVqI4+TFh21Vctot55a+hsD47JPs3T6sKS1wMzt4S4IERN4ZGVqI4+TFh21Vctot55a+hsD43b1Ne0tFhAq4M)KsA4IEqznFSSrxFb5E62DNUViM4XxZUN)Mqb3H5An1qN9xMStF3sIEebMZ3QqmM)K1cSWI4r6t5NyZA5DVUMPN6XeMMmqFqz6CcS1QvN4ZGVq4M)KFhA1xxAt1qmaQ6tFZSVJV7ctF4S1NDcwQGXXVZMzZGEPxMETxWs3NANnF3QoxvERVU4q4MAT1qt1Q5/RQR23MSAtFxrItvV)Zv21VDTosUEaNDN545b3NUTZF3siQ4A/VAVWI4rat5NKZ6N4EU43H5ATQKS1wvEDxUVqN7AttAMaw6t5V63PHAras6rbxMS/Z74KH5caFGsydRNGE90Rs3TCF3siQ4A/VAVWI4rat5NKZ6QDVU4KIMzzQKt++RNU+4S34Z2/s3NGHSAF4SVNtMzzQKt++RNU+4S34Z2/s3NGdRN4Z4SXx4rns6teQMzt+4S34Z2/sSJe+c5R4YfPsStZMx41wvmRmv2NN5caF7BetvN)s6zJmZ2Yt5NIMqz6CcSRHAtotAS+E5ETx5pPNW2rsWmawxN5EUX1NRzhFGQqHFb)x62qHUctFxrItvV)Zv21wAtrs6BqEqz6CcXxxFSrZ5trx4A5MKVqVW2itWsbxM3Rs6X3VStZmKS+N6N)d7fPNAVnF5t1wMrSx5s3NUTE1Ks2tMz6CcS1QvN4dMcI4qSwEeS1xxAt1qmaQ6t5x6XNNqztF4S1Nq4vdUAA4DnrZGEPxMETx5s3NUTEQcMq1vETF7S1x4t4ZGVq4M)KsA4IxMzaFGsKQUNFM4SXw5TSQRrVQ5z/4Y03MhVEtA42xvN)+4SXw5TSQRrVQ5z/4Y03MhVEM4MqtFb5V6SKIMzzQKt++RNU+4SNMhViQc4xCqz6HhANwWNZZ5trxvERMcVKNUVosAMqQ5z6H7s1VKNT1Rr+Q6N)d4SXw5TSQRrVQ5/RsU0KxMzz4SspHMMT+4SNNAtoM4MqZ9b)46z3VW2CM4MqMRmTF7SXx7nTNZSrx4A5470N4ZNEFWS1wMMT1xAWI4rC1qma+vmqEAN1Ne0rmqspQ5z/43s3MGXZsSJoxMS6d6SAIxAtQKsZMRV5+D0q4ZNas3NZHvtF43s3MGXZF3siVeb)d3bqN7AtFWS1wM4wERSAIxAtF5t1wMVwVMNWNDnaF7BoxMStQMbANYSrZ5trxvV5mvAqsSrY1Rt+M5z6H7s1VctotAQcxMStF3sbxGJeNZ4145)K1cSWI4r6t5NrtMz6CcS1QvN4ZGVq4M)KsA41xxAt1qmaQ54SF7S1x4t4ZGVq4M)KsA4IxMzaFGsxdDN2EAJPshNZF3QoxMzCMxTxFK4FNMcq4Mzt+4SqVK2TQKS1wM/R4hlPsStCsRrAxMETxUXDNAtot55aQYb54SV3wUctF4S1Nq)csW4IEqT4ZGEPxMETxUXDNAtot55axvNSF7S1xM4rZ3Qe4M4wxW4AxMzaFGsGZ9b5E62DNAroMZsIMcAtF7S1x4t4ZGVq4M)K1D4XIMzaFGsGZ9b5E62DMS+osRrG+hNDFSSXxMz6ZSs+VMMKZxTIEebtmKS++ht54703mZ2ns6teQMz6CcS1FqXGF4sV14tVxA41xxAttWmaVDN546A1Ne0tsRrMQvNDFSSWI4rYs3NydRN5E5n3HWlKs5t1wM/Rd70qNUttmKS++htF4Y0RHUVYs6t+Z6N)14SXw5TSQRrVQ5/R+qnNN6XoQDEaVc5DN4SXw5TSQRrVQ5/R+qnNN6XoQDEaHvs)4S21NRznMxBqMqETxUXDMS+otAXKZAA4MRSqtMzzQKt++RNU+4S3VW2ns6teQvt54hXNN5ctF4S+QUNFQcVNVcteMMNVxMETx63PHUVZs3NxQSA5Z4SXx4ratAXKMc5R4hXNN5ctmKS++xNF4hzK44VotAS1wM/RxU0KV3Tot5+eNRN)46Aqs3ztmKS+FREDMR2qN3zzFGsydRN5tSSWI4rFs3NxdDmTF7S1x4t4ZGV2VxcCEcNXI4BaZ5trxxN)MqpPtMzzFU4+Qhs)+cS3M7ctFxraxvmRm42qH5TG1qNaxMS/QASKHANat5NxM5z6HhANwWNZZ5trxxN4mvAqHAN6F5t1wMrSx5bKNAVn1qN9xM3Rs6X3VStZZ6tnQ5/RmvSRHUVtMZQqQhs5VU41NRzhFGQqHFb)x62qHUctFxrItvV)Zv21VcVTs3N2HSAZE6AJsGXZF3Qox4AFZhXK44V6FSSrxxN545nqMSroQRrMERtFZSNN4MctF4S+FRV4mvARH54tmKS+QMrDESVNtMzzHU4+H7NtEhXRs3ztmKS+dDNtE7rNVK2GtWsbxMETxUARs3T6sK3ewvNDxU014Z2TFS4yQ7mRd4SWI4rcFSVGE5ETx5s34MATQc42w5z6H7s1VKNT1Rr+Q6N)d4SXVRNetWtxMqnU+4SqVSritWsaxMS/QASq44VCQc42HFb5Z4SXNqXrNZ3z+METxAV3VqAttAMqEqz6HhANwWNZmKS+McAFdASXw5TSQRrVQ5/RV5bNmZ26t5NydcAtF7S1x4tvNvAAFDcC4S4Ix4BamKS+M6s)dh2NN5AMF3sitq/RV63PHAras6rbxMS/Z74KH5caFGsGdRN4V5b1NRz3FGsYH7N4+4SWI4rSs6tqMDmRQcV1xxAtZAS+QqnU+4S3HW25s6rGMDN/d4SXw62tsWs2QUN2EWEPHUVes5NVxM3Rs6X3VStZmKS+VebD4hADNUTesA4IMcAtF7SKVSrGs6tGE5ETx5NRsStG1RryFqz6H7s1VqACM4MqNRV2EUMPs3TitU41wMrSx5bKNAVn1qN9xMS/Z74KH5caF7rqQ7mDVAV1Ne0y43QcHMMDQv21VDVetUBqQ7N2E6XNwAroQcXAxMS/QA3PNW2atAX1xMStF3sIERN4ZGVq4M)K1cSWI4r6t5NydcAZEAV3VKNYF5t1wMztN4NIEcBTF4ze4MTtFh21VctotAMatvt5EUAN4Z2CsRtIMqz6CcS1Fq4MNMpKFqSVNFS1xxAtsWtZHFb)+R/PtMzzQKt++RNU+4SNM3TMtA4VxMStxUX3N5TZMZQzxMETx5bKNAVn1qN9xMS/Z74KHWmamKS+FRs)dSV3w5TEQKsZMRVSF7SJt4BRtAJPxMS6VxAWNDnaF7rxMhsDZ3sRIMzzQKt++RND+K2EdZq0JYaYtU47txTKwvtSJG/YFU4+QhsDFSSXw62t1RrxQvsDs6XK44VotAEa+7N5ZSV1Ne0t1RryMYbDMqb1xxAtsAMqVRt5m4SqxMzzsWs2QAA5Zv21VqTZsAEaQYpRs5n3HWlKs5t1wM/Rs62Rs7n9F6r2M3zt+4Sq4ZmRs3N2xvNZE6S3M3TisUBKxM3Rs6X3VStZmKS+ERN)s5aPHABRsSX+McA5V6A1Ne0ymqspQ5/RZSVqMK2e1KsqZ6EDx6zqN6VZM4S1wM/RxU0K4MXtmKS+ERN)s5nqVDTiMM5aQhN4mxAK44V5s5t1wvmRmv2NN5caFGsIMRNZEWs344Vrs3N2EcA2E5mPs3ztFMsAHMMT+4Sq4ZmRs3NiHhEDZSVNMK2t1RtxMqz6CDAWNDnaFGsIMRNZEUbRs3Tns6t+ZAA4QhXNN5ctFMspHMMT+4Sq4ZmRs3NiHhEDZSVNMK2S1RrMw6NUF7Sx4DnTNZSrxvN4VWsDN6ziQKtIMcAZE5bN4ZNZsWS1wM4S1xAWI4BKs6rqZ6QRMRAK4ZNSsSXxQMr)dSV1Ne0tMMNZHvNUFh21VqTMtAEa+vsDZ3sRmZ2Y1Rt9xMS6mSNWNDnaFGsI4UNZEUARs3T6sq5a+hs)14SXxv5zFM+z+METxWVJHANEM44ZQFb5Q3n3HWlKs5t1wMz/4hz3VqctmKS+Eqr)45nN44Vn1qNeZA5RmvSqIMzzNZ3z+METxWVJHANEM44ZQFb5Q3nNMGJKF3QoN5MT1xAWI4BKF6rMZ5r)m4XDNUVeFWS1wM4wm7AWNDnaFGsI4UNZEAmPshVEt6rZHMz6CDXAx3XrmqspQ5/RZSN3MK2M1RtKZUN)EWVqN3zzF7rxH7mRZ4SWI4BKF6rMZ5r)m4XDMSretWsbxMS6dxVWNDnaFGsI4UNZEAmPshVEM4JeEqz6CqNAIFSrmKS+MDmRm4S34MctFZsqQ7mD4SVWI4BRs5t1wvmRmv2NN5caFGsqMRt5mv2KIMzzsWs2QAA5Zv21VRNZsSJeMRN)QASXVRNetWtxMqETxWsqVW2CtWs2+vt5ZSV34MAMF3QoFqV6d621VK2C1DEa+vsDZ3sRmZ2eF3Qo+3SvERSAIxAttAXxNRtFEhzK44+os3N1xMStQFSXNYSrmKS+dcA543nN44Vn1qNeZA5RmvSqIMzzNZ3z+METxU0NNAtEM44ZQFb5Q3nNVqAns5t1w4tt1xAWI4rrsRtINRQTF7SAIFSrmKS++vsDZ3sRmZ2Yt5NIMqz6CcSq4Z2FtAS1Q5z/4SXqHWNrs3NqtxN5Q4SXxvAMNZ3z+METx5bKNWNZMM5aCDN5dGV1Ne0SmqspQ5z/4SXqHWNrsSX+Q7mRd4SXNq4CmqspQ5z/4SXqHWNrsSX+QhV4Z4SXNebTNZSrx4AFQcVqsGXEQc47xMS6EDAWNDnaF7rZQhVSF7SAIFSrmKS+49bDQqn3VSrEsWtbxMS6F74WNDnaF7rZQhVGE62NMK2as6rqQMz6CDXxNDnTNZSrxMr)m4XDNUTSsSX+Q7mRd4SXNq4CmqspQ5z/MRXK+K2aM4Eatvs)Qe0KIMzz43spHMMT+4SJH5AFs3NGdRN4Z4SXx4rosWQPxMETxAmPshVEM4JeH7NZEWsNVK2YF3Qo+34wm7AWNDnaF7rZQhVGE5bN44VTsSX+Q7mRd4SXNq4CmqspQ5z/MRXK+K2CM44ZHvtF47AqIMzzN4zpHMMT+4SJH5AFsSXx+vs)45nK4xttFMQc1MMT1xAEN7At1RrZtMz44743MGN6sc4ZHvNSF7SJt4re1cXIHhERmvARHW2Ts3NGdRN4Z4SXx4retWtKQ3rDN4SWI4BKs6rqZ9b)xWs1NRznMxBqMqETxWVqH6NE1Rr+VRt5+D0q4MctF4S+VDN4MDA1VSVeQD41Q5/RZSVqMK2e1KsqZUmRE6ARH6NMF3siQ4A/VAVWI4BKs6rqZ9b)xWsDMSrZMMmqQMz6CD4WNDnaFGsIMRNZE6JPVRNEQKt+HhN5QcVNxMzzFGs+dRV4mSSWI4BKs6rqZ6mRdhzNmZ2esA42+vV4MqNqN3zzsWs2QAA5Zv21VqTZsAEaVDN4MDADN55KMM5aN9bDFSSXNq4TNZSrxvN4VWsDN6ziQKtIMcAZEA3PsStZF3Qo+Stv1RSAIxAtsAMqVRt5HhzKV3TZM4Ea+vs4mMbqN3zz43sbHMMT+4Sq4ZmRs3NiHhEDZSVNMK2S1RrMw6NUF7SXx7nTNZSrxvN4VWsDN6ziQKtIMcAZE5bN4ZNZsWS1wM4t1xAWI4BKs6rqZ6QRMRAK4ZNSsSXxQMr)dSV1Ne0ttWQaHSA5Z4SWI4BKF6rMZAA4MR5PN6XEt6r21Mz6CDXxNqXTNZSrxvmDMRSDMGXiQc4xCRt5+Rz3xMzzmcz945V6d621VqTMtAEa+vsDZ3sRmZ2Yt5NIMqz6Cc3PVK2GtWsxMqzt+4SqVSVTsSJeHhV44Y0DMSretWsbxMS6F74WNDnaFGsI4UNZEUARs3T6sq5aFcA4d4SXNebMmqspQ5/RZSN3MK2M1RtKZUN)mFS1Ne0yF4spHMMT+4SqVSVTsSXZQhVGEUXRH9StF4Snd3Svd6SAIxAtsWtZHvtFMRXK+K2Yt5NIMqz6Cc3PVK2GtWsxMqzt+4SqVSVTsSXZQhVGEUMPHAmKF3QoFq4S1xAWI4BKF6rMZ5r)m4XDMStrsWS1wM4wm74WNDnaFGQqHFb)x62qN3zzsWs2QAA5Zv21VRNZF3siVeb)d3bqN7AtsWQqZ9b)dhA1NR/R1RryFRNU+4SqVKNEM4MqMRsSF7SqVqAaMMNVQ5/RsAVDMStT1R+eZ6N4V6lPsGVtFMsAHMMT+4S3MSt6sSJeHhV44Y0DNW4tF4Sn1MSU1xAWI4roMMNxZAA4MR5PN6XE1cS1wMVwmSNWNDnaFGQaFebGEUARs3T6sq5atFb)4WV1Ne0rmqspQ5/RE5pP+K2rsRtINRs2EUMPs3TZF3QoN5V6d621wWXiQc4xCqz6CDAWNDnaF7BeHhV44Y0DNUVosA4VxMStx5bqHUVimR+q+Mzt+4SNMhVZs6+eZ6N/xU03N3zzmc/K+MV6d621wAtFs6Bq+vt5Q7034xctFMs1HMMT+4SNMhVZs6+eZA5RmvSqIMzzNMbAHMMT+4SNMhVZs6+eZA5RmvAqN3zz4S3z+METx5bKNWNZMM5aQxNSF7SXx7nTNZSrxMr)m4X1Ne0rmqspQ5z/MRXK+K2aM4EaERETF7SXIFSrmKS+49bDQqn3VSrEtAMqVRETF7SWxYbrmqspQ5z/MRXK+K2aM4EatFb)4WV1Ne0CNxMz+METxAmPshVEtWt+ZA5RMDrRV7ctFMQP+MV6d621wAVeQDEa+7N5ZSV1Ne0tM4JeH7NtFh21wAVeQDEaFcA4MRSDN6NSt5NnxMStQxTX4DnTNZSrxMr)m4XDMStrsRrMZA5RmvSqIMzz43+z+METxAmPshVEM4JeH7NZE5bN4xctFMQc+MV6d621wAVeQDEaFcA4MRSDM3ToF3Qod3Svd6SAVhAaFGsxtxNFV5sR44VTsU41wMrSx6JPM3TiQKs2Qvs)E6SDNUVosA4VxMStx6X3VhVeF6tAxMETxWVqH6NE1Rr+Vqz6HGQPHUTCs5trxvN4VWsDN5AtsAEa+7N5ZSV1Ne0tsWsyHS5TESmPsSAtmKS+ERN)s5aPHABRs3NMdRV4MKsJN3zzsWs2QAA5Zv21VqTZsAEaQYpRs5nNVKNCs6tbxMS6NvSAIxAtsAMqVRt5m4SqMK2nMZsZw6N5VU41Ne0tt6rZFcASFh21VqTZsAEaVDN4MDADN55K1R+eQvsDsAV1NR/R1RryFRNU+4Sq4ZmRs3NqQ6sDE3aPH5TrsSXqQSAtF7SAtFSrmKS+ERN)s5nRVcVnQcMqtvt5x6XNN5ctFMspHMMT+4Sq4ZmRs3NiHhEDZSVNMK2rsc42FRNUF7SAIFSrmKS+ERN)s5nRVcVnQcMqtvtFx6X3VRVZF3QoQMMT1xAWI4BKs6rqZ6QRMRAK4ZNSsSXx+vN)VWV1Ne0CmqspQ5/RZSVqMK2PsRtIQvNDx5nNM3TMtA4VxMStx5bRHANZFSSrxvmDMRSDMGXiQc4xCRt5+RXJIMzzF4QKHMMT+4SqVSVTsSJeHhV44Y0DNUVitAS1wMVwmSNWNDnaFGsI4UNZEUARs3T6sq5a+7N5ZSV1Ne0tMMNZHvNUFh21VqTMtAEa+vsDZ3sRmZ2S1RrMEqz6CDAWNDnaFGsI4UNZEUARs3T6sq5aFcA4d4SXNebrmqspQ5/RZSN3MK2M1RtKZUN)mFS1Ne0yF4spHMMT+4SqVSVTsSXZQhVGEUXRH9StF4Snd3Svd6SAIxAtsWtZHvtFMRXK+K2Yt5NIMqz6CcSNNAVTs5t1Q5/RZSN3MK2M1RtKZA5RmvSqIMzzNMbAHMMT+4SqVSVTsSXZQhVGE5bN4xctFMQP+MV6d621VKNT1Rr+Q6NUF7SKVSrGs5trxvmRZ4SXVRNetWtxMqETxWsqVW2etWtbxM3Rs6X3VStZmKS+VRmqEUAqHWNmF3siVeb)d3bqN7AtsWQqZAA546XNmZlKs6ryQ3rUF7SAtFSrmKS+dcA543nN44Vn1qNeZ9bUF7SWx3XMmqspQ5/RE5pP+K2rsRtINRs2EAS1Ne0YF4QKHMMT+4S3MSt6sSJeHhV44Y0DMSretWsbxMS6d6SAIxAttAXxNRtFEhzK44+osSX+QhV4Z4SXNebTNZSrx4A4MR5PN5XtFMs945V6d621wWXiQc4xCRt5+D0q4MctF4S+MDmDMqbRH5ATFSSrx4AFQcVqsGXEsUr+dDNUF7SWxGVrmqspQ5z/4SXqHWNrs3NedDN4d4SXNqzTNZSrx4AFQcVqsGXEMZs2HvmTF7SAFq4TNZSrx4AFQcVqsGXEMZs2QvNUF7SxxFSrmKS+FRV5VAVNmZ2ntU41wMSwd6SAIxAtF6r2M3z6CDAWNDnaF7rZQhVGE62NMKlKQKS1wM3T1xAWI4rM1RtKZUmDx5n34ZmRQKS1wMVw1DAWNDnaF7rZQhVGE62NMK2S1RrMEqz6CqbAtFSrmKS+49bDQqn3VSrEMZsZw6QDd4SXNebrmqspQ5z/MRXK+K2Yt5NIMqz6CcS3MGXrtAXxHhV4Z4SWI4rM1RtKZAAFEhz3MKlRMZQa+3z6CDXAx3XrmqspQ5z/MRXK+K2CM44ZHvtFx6X3VDctFMsAFqV6d621wAVeQDEaFcA4MRSDMStrsWS1wM4wd6SAIxAtF6r2MhtF47ARHANEQc47xMS6VFSAIFSrZ5trxvN/xAVqsStn1RrMERs)4Ur1NRzhFGs2NRV4MqmPs3Tit5NMZUN)EWVqN3zzFGs2Q6V5m4NNtMzaFGsIMRNZE6JPVebtFZsqQ7mD4SVWI4BKs6rqZ9b)xWsDNUVosA4VxMStxWs344VrFGtZQhVSFh21VqTZsAEaQYpRs5n3VK2nsRrq45z6HhANwWNZmKS+ERN)s5aPHABRsSX+McA5V6A1Ne0CmqspQ5/RZSVqMK2e1KsqZ6EDx6zqN6VZM4S1wM/R+RzNM34tmKS+ERN)s5nqVDTiMM5aQhN4mxAK44V5s5t1wvmRmv2NN5caFGsIMRNZEWs344Vrs3N2EcA2E5mPs3ztFMsAHMMT+4Sq4ZmRs3NiHhEDZSVNMK2t1RtxMqz6CDAWNDnaFGsIMRNZEUbRs3Tns6t+ZAA4QhXNN5ctFMspHMMT+4Sq4ZmRs3NiHhEDZSVNMK2S1RrMw6NUF7Sx4DnTNZSrxvN4VWsDN6ziQKtIMcAZE5bN4ZNZsWS1wM4S1xAWI4BKs6rqZ6QRMRAK4ZNSsSXxQMr)dSV1Ne0tMMNZHvNUFh21VqTMtAEa+vsDZ3sRmZ2Y1Rt9xMS6mSNWNDnaFGsI4UNZEUARs3T6sq5a+hs)14SXxv5zFM+z+METxWVJHANEM44ZQFb5Q3n3HWlKs5t1wMz/4hz3VqctmKS+Eqr)45nN44Vn1qNeZA5RmvSqIMzzNZ3z+METxWVJHANEM44ZQFb5Q3nNMGJKF3QoN5MT1xAWI4BKF6rMZ5r)m4XDNUVeFWS1wM4wm7AWNDnaFGsI4UNZEAmPshVEt6rZHMz6CDXAx3XrmqspQ5/RZSN3MK2M1RtKZUN)EWVqN3zzF7rxH7mRZ4SWI4BKF6rMZ5r)m4XDMSretWsbxMS6NMbWNDnaFGsI4UNZEAmPshVEM4JeEqz6CqNAIFSrmKS+MDmRm4S34MctFZsqQ7mD4SVWI4BRs5t1wvmRmv2NN5caFGsqMRt5mv2KIMzzsWs2QAA5Zv21VRNZsSJeMRN)QASXVRNetWtxMqETxWsqVW2CtWs2+vt5ZSV34MAMF3QoFqV6d621VK2C1DEa+vsDZ3sRmZ2eF3Qo+3SvERSAIxAttAXxNRtFEhzK44+os3N1xMS6mSNWNDnaFGQaFebGEUARs3T6sq5atFb)4WV1Ne0rmqspQ5/RE5pP+K2rsRtINRs2EUMPs3TZF3QoN5V6d621wWXiQc4xCqz6CDAWNDnaF7BeHhV44Y0DNUVosA4VxMStx5sKsStnt5NnxMETx5bKNWNZMM5aVc5REUX1Ne0YF4zpHMMT+4SNMhVZs6+eZ6s4E62qIMzzN43z+METx5bKNWNZMM5atFb)4WV1Ne0rmqspQ5z/4SXqHWNrsSX+QhV4Z4SXNebTNZSrx4AFQcVqsGXEQc47xMS6EDAWNDnaF7rZQhVSF7SAIFSrmKS+49bDQqn3VSrEsWtbxMS6mhSAIxAtF6r2Mht5d74DNUTZsUrbxMStQMNAIFSrmKS+49bDQqn3VSrEMZs2HvmTF7SAFq4TNZSrxMr)m4XDNUTSsSX+HhN5QhA1Ne05NZ3z+METxAmPshVEt6BaERNUF7S1VK2rM4MaFRsDZSV1xxAtF6r2MhtF47ARHANEsUr+dDNUF7SWxGMzNZ3z+METxAmPshVEM4JeH7NZEUMPHAmKF3QoFq4S1xAWI4rM1RtKZAAFEhz3MK2CM44bxMS6VxAWNDnaF7rZQhVGE5bN44VTsSXIdqz6CDTX4DnTNZtnQ5/R+RX3wWNetW3eQYbUF7SJt4re1cXIHhERmvARHW2Ts3NGdRN4Z4SXx4BosRtIQFb)x62qNGXotWsy45zt+4Sq4ZmRs3N2xvNtF7SKVSrGs5trxvN4VWsDN5AtsAEa+7N5ZSV1Ne0tsWsyHS5TESmPsSAtmKS+ERN)s5aPHABRs3NMdRV4MKsJN3zzQKt++RNU+4Sq4ZmRs3N2xvNZEU4qsStZQKS1w4tU1xAWI4BKs6rqZ9b)xWsDM3TSsRrKw6NDFSSXx4rYsRtxFqzt+4Sq4ZmRs3NqQ6sDE3aPH5TeMZtIHhERZ4SXVRNetWtxMqETxWVqH6NEsWsyHSA2E6XqVGXEQKs2tMz6CqbWNDnaFGsIMRNZEUbRs3Tns6t+Z9pRmMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMGJo1RtxMqz6CDAWNDnaFGsIMRNZEUbRs3Tns6t+ZA5RmvSqN5ctFMsb+MV6d621VqTZsAEawRsDZhAqsSrEM4JeMRN)d4SXNq4TNZSrxvN4VWsDN6ziQKtIMcAZE5bKVSVas5t1wMz/4hz3VqctmKS+Eqr)45nN44Vn1qNeZUN)mFS1NefzFM+z+METxWVJHANEM44ZQFb5Q3n3HAVTF3Qo+3SvERSAIxAtsWtZHvtFEhzK44+os3NGdRN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DMSretWsbxMS6d6SAIxAtsWtZHvtFEhzK44+osSXx+vmTF7SxNDnTNZSrxvmDMRSDMSVeQDEa+YbDmSSXNKMzNZ3z+METxWVJHANEF6r2Mht5+Rz3xMzzmc/c1MMT1xAWI4BKF6rMZ5r)m4XDNUVosA4VxMStx5bRHANZFSSrxvmDMRSDMSVeQDEatFb)4WV1Ne0CNxMz+METxWVJHANEF6r2MhtF47AqIMzz43spHMMT+4SqHANe1KsyMqz6HGQPHUTCs5trxvmRZ4SXVRNetWtxMqETxWsqVW2etWtbxMS/Z74KH5caFGsqMRtFESVqH62tFxrItvV)Zv21VRNZsSXxHFbDE3nq4ZNa1R+KxMS6NvSAIxAttAXxNRtFEhzK44+os3mcxMStQFSXNYSrmKS+dcA543nN44Vn1qNeZ9btF7SWx3XMmqspQ5/RE5pP+K2rsRtINRs2EUMPHAmKF3QodStU1xAWI4roMMNxZAA4MR5PN6XEMZs2QvNUF7SxxFSrmKS++vsDZ3sRIMzzNZ3z+METxUARs3T6sq5a+7N5ZSV1Ne0t1cJqFRV4EUX1xxAtM4XKMRNDE3nqwArot5t1wMVwEDAWNDnaF7rxMhN)VUADN6XotA4bxMS6dvSAIxAtM4XKMRNDE3nNVqATsWS1wM4CNvSAIxAtM4XKMRNDE3nNVqAns5t1w4+T1xAWI4rCQqmqMcA2E6A3tMzzF4zpHMMT+4SJH5AFF3Qo+MV6d621wAVeQDEaQAAZEWVKIMzz4S3z+METxAmPshVEtWt+ZUN4VWsKIMzzNZ3z+METxAmPshVEtWt+ZA5RmvSqIMzzNMbAHMMT+4SJH5AFs3NytvtFx6zqN6XnF3Qo+MV6d621wAVeQDEa+7N5ZSV1Ne0ttAJe+xNF4hzK4MctmKS+49bDQqnNMGXitAEaVc5REUX1Ne0YN4z1N5V6d621wAVeQDEaFcA4MRSDMSretWsbxMS6NMbWNDnaF7rZQhVGE5bN44VTsSXx+vmTF7SAxYbTNZSrxMr)m4XDMStrsRrMZ6V4tSSXNKMzNZ3z+MnU+4SNwWNTtWsZHvNSF7SJt4re1cXIHhERmvARHW2Ts3NGdRN4Z4SXx4BosRtIQFb)x62qNGXotWsy45zt+4Sq4ZmRs3N2xvNtF7SqVqAaMMNVQ5/RZSVqMK2e1KsqZUN)EWVqN3zzFGsqQ6sDd5XJH5AFFSSrxvN4VWsDN5AtsAEaHxNFZhzqwWVtFxrItvV)Zv21VqTZsAEaQYpRs5nNVKNCs6tbxMS6FhSAIxAtsAMqVRt5m4SqMK2nMZsZw6N5VU41Ne0t1KQaQvQTFh21VqTZsAEaVDN4MDADN55K1R+eQvsDsAV1NR/R1RryFRNU+4Sq4ZmRs3NqQ6sDE3aPH5TrsSXqQSAtF7SAtFSrmKS+ERN)s5nRVcVnQcMqtvt5x6XNN5ctFMspHMMT+4Sq4ZmRs3NiHhEDZSVNMK2rsc42FRNUF7SAIFSrmKS+ERN)s5nRVcVnQcMqtvtFx6X3VRVZF3QoQMMT1xAWI4BKs6rqZ6QRMRAK4ZNSsSXx+vN)VWV1Ne0CmqspQ5/RZSVqMK2PsRtIQvNDx5nNM3TMtA4VxMStx5bRHANZFSSrxvmDMRSDMGXiQc4xCRt5+RXJIMzzF4QKHMMT+4SqVSVTsSJeHhV44Y0DNUVitAS1wMVwmSNWNDnaFGsI4UNZEUARs3T6sq5a+7N5ZSV1Ne0tMMNZHvNUFh21VqTMtAEa+vsDZ3sRmZ2S1RrMEqz6CDAWNDnaFGsI4UNZEUARs3T6sq5aFcA4d4SXNebrmqspQ5/RZSN3MK2M1RtKZUN)mFS1Ne0yF4spHMMT+4SqVSVTsSXZQhVGEUXRH9StF4Snd3Svd6SAIxAtsWtZHvtFMRXK+K2Yt5NIMqz6CcSNNAVTs5t1Q5/RZSN3MK2M1RtKZA5RmvSqIMzz4SsVHMMT+4SqVSVTsSXZQhVGE5bN4xctFMQP+MV6d621VKNT1Rr+Q6NUF7SqVqAaMMNVQ5/RsAV1NR/R1RryFRNU+4SqVKNE1RryQMz6HGQPHUTCs5trxvmRV5nN4ZNZsD41wvEDxUVqN7AtsWQqZAA546XNmZlKs6ryQ3rUF7SxIFSrmKS+dcA543nN44Vn1qNeZ9bUF7SWx3XMmqspQ5/RE5pP+K2rsRtINRs2EAS1Ne0YF4QKHMMT+4S3MSt6sSJeHhV44Y0DMSretWsbxMS6d6SAIxAttAXxNRtFEhzK44+osSX+QhV4Z4SXNebTNZSrx4A4MR5PN5XtFMs945V6d621wWXiQc4xCRt5+D0q4MctF4S++c5TFh21wAtFs6Bq+vt5sU43N6AtF4Sn45MT1xAWI4rCQqmqMcA2E903NU)KF3QotMV6d621wAtFs6Bq+vtFx6X3VDctFMsAFqV6d621wAtFs6Bq+vtFx6XK4MctFMQPHMMT+4SNMhVZs6+eZ6V4tSSXNKVrmqspQ5z/MRXKtMzzNZ3z+METxAmPshVEtWt+Z6mDd4SXNqzTNZSrxMr)m4XDNUTSs3NyMRN/d4SXxvA5NZ3z+METxAmPshVEtWt+ZA5RmvSqIMzzNMs1HMMT+4SJH5AFs3NytvtFx6zqN6XnF3QoN5MT1xAWI4rM1RtKZUN)EWVqN3zzF7rxHhN4VAJPsSVCFSSrxMr)m4XDMStrsRrMZ6N/xU03N3zzmc/c1MMT1xAWI4rM1RtKZAAFEhz3MK2S1RrMEqz6CDAWNDnaF7rZQhVGE5bN44VTsSXx+vmTF7SANYSrmKS+49bDQqnNMGXitAEaQxNSF7SAx3XrmqQeE5ETx5pPH6NZFS4eMeb)d4SXw62t1RrxQvsDs6XK44VotAEa+7N5ZSV1Ne0t1RryMYbDMqb1xxAtsAMqVRt5m4SqxMzzsWs2QAA5Zv21VqTZsAEaQYpRs5n3HWlKs5t1wM/Rs62Rs7n9F6r2M3zt+4Sq4ZmRs3N2xvNZE6S3M3TisUBKxMS/Z74KH5caFGsIMRNZE6JPVRNEMZQqFRNDd4SXNq4TNZSrxvN4VWsDN5AtsAEaQ45RMDrqNWNSF3QoxxN)MqbNtMzaFGsIMRNZEWs344Vrs3N2EebDEhARshNZF3siVeb)d3bqN7AtsAMqVRt5s62RsGXE1RrI+vtFs6XNxMzzNxMz+METxWVqH6NEsKsZQvV4VU4DNAreMMNVxMS6d6SAIxAtsAMqVRt5HhzKV3TZM4Ea+vs4mMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMSretWsKMqz6CRAAIFSrmKS+ERN)s5nRVcVnQcMqtvtF47AqHWmKF3QoFqV6d621VqTZsAEawRsDZhAqsSrEM4XI4UN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DNUVeFWS1wMSvERSAIxAtsWtZHvtFEhzK44+os3NGH7NtF7SWx3XMmqspQ5/RZSN3MK2rsRtINRs2EUX3N5TZF3Qox4A5MRSqN3zaFGsI4UNZEUARs3T6sq5atFb)4WV1Ne0rmqspQ5/RZSN3MK2rsRtINRs2E5bN4xctFMQP+MV6d621VqTMtAEa49bDQqn3H55zF3Qod3Svd6SAIxAtsWtZHvtFMRXK+K2YsRBzxMStQxTX4DnTNZSrxvmDMRSDMSVeQDEa+7N5ZSV1Ne0tMMNZHvNUFh21VqTMtAEa49bDQqnNVqATsWS1wM4CNvSAIxAtsWtZHvtFMRXK+K2CM44bxMS61DAWNDnaFGQqHFb)x62qN3zzQKt++RNU+4SqVqctFZsqQ7mD4SVWI4BRsWmaQ7mDd4SXVRNetWtxMqETxWsqVW2rs6BqM5z6HGQPHUTCs5trxvmRV5nNNANeMM5aERN)dhXJN3zzNxMz+METxU0NNAtEM44ZQFb5Q3aPN3zzmcz945V6d621VK2C1DEa+vsDZ3sRmZ2tF3Qo+3SvERSAIxAttAXxNRtFEhzK44+osSX+Q7mRd4SXNDnTNZSrxxNF43sDMGXiQc4xCRtFx6XK4MctFMQPHMMT+4SN44Vn1qN9xMS6d6SAIxAtM44ZQFb5Q3n3HWlKs5t1wM/RV62JsSti1RBzxMETx5bKNWNZMM5aVc5REUX1Ne0YF4zpHMMT+4SNMhVZs6+eZ6s4E62qIMzzN43z+METx5bKNWNZMM5atFb)4WV1Ne0CNxMz+METx5bKNWNZMM5atFbDZSV1Ne05mqspQ5z/4SXqHWNrsSXIdqz6CcNAIFSrmKS+49bDM4SXNDnTNZSrxMr)m4XDNUTSs3NIQMz6CqNWNDnaF7rZQhVGE62NMK2as6rqQMz6CDAWNDnaF7rZQhVGE62NMK2S1RrMEqz6CqbAtFSrmKS+49bDQqn3VSrEMZsZw6QDd4SXNDnTNZSrxMr)m4XDNUVosA4VxMStx5bKNWNZMZS1Q5z/MRXK+K2CM44ZHvt5sU43N6AtF4Snd3Svd6SAIxAtF6r2MhtF47ARHANEMZs2HvmTF7SAFq4TNZSrxMr)m4XDMStrsRrMZAAFEGV1Ne0CNZ3z+METxAmPshVEM4JeH7NZE6A3tMzzN4z9+MV6EG2WI4rCtAMaMhs)4Ur1NRzhFGs2NRV4MqmPs3Tit5NMZUN)EWVqN3zzFGs2Q6V5m4NNtMzaFGsIMRNZE6JPVebtFZsqQ7mD4SVWI4BKs6rqZ9b)xWsDNUVosA4VxMStxUMPHAmKt5Nnm3r)m4X1xxAtsAMqVRt5m4SqMK2TtAXIHhN/EcSXw5TSQRrVQ5/RZSVqMK2e1KsqZA5RV5bqs7ctFMsAHMMT+4Sq4ZmRs3N2xvNZE6ANVcV/s5mqtMz6Cc3PVK2nsKS1Q5/RZSVqMKlRtA4Z+vt5mZEPsGXnsRtqMqz6HGQPHUTCs5trxvN4VWsDN6NasR+eZ9b)Z7ADMhNeM4S1wM4S1xAWI4BKs6rqZ6QRMRAK4ZNSs3N+QSA5Z4SXNDnTNZSrxvN4VWsDN6ziQKtIMcAZEUAR4MACs5t1wMMT1xAWI4BKs6rqZ6QRMRAK4ZNSsSX+Q7mRQcV1Ne0nNZ3z+METxWVqH6NEsKsZQvV4VU4DMStrs6BqEqz6CqbWNDnaFGsIMRNZEUbRs3Tns6t+ZAAFZSN34MctF4S+FRs)4AV1xxAtsWtZHvtFEhzK44+os3NGQ3BTF7SX4KVTNZSrxvmDMRSDMGXiQc4xCRt5+Rz3xMzzmcz945V6d621VqTMtAEa+vsDZ3sRmZ2Yt5NIMqz6CcSNNAVTs5t1Q5/RZSN3MK2rsRtINRs2EUMPHAmKF3Qo+MV6d621VqTMtAEa+vsDZ3sRmZ2CM44bxMS61DAWNDnaFGsI4UNZEAmPshVEt6r21Mz6CDTX4DnTNZSrxvmDMRSDMSVeQDEa+hs)14SXxvAyF4spHMMT+4SqVSVTsSXZQhVGEUX3N5TZF3Qox4A5MRSqN3zaFGsI4UNZEAmPshVEMZs2HvmTF7SAFq4TNZSrxvmDMRSDMSVeQDEaFcA4d4SXNebrmqspQ5/RV63PHAras5t1wvmRmv2NN5caFGsqMqz6HGQPHUTCs5trxvmRV5aPHUTnF3siQ4A/VAVWI4BRsWma+vN)VA21NRznMxBqMqETxWsqVW2CtWs2+vt5ZSV34MAMF3QodS+T1xAWI4roMMNxZAA4MR5PN6XE1qt1wMVwmSNWNDnaFGQaFebGEUARs3T6sq5axMz6CDXX4KVTNZSrxxNF43sDMGXiQc4xCRtFx6X3VDctFMspHMMT+4S3MSt6sSJeHhV44Y0DMSreQc4VxMS61RSAIxAtM44ZQFb5mSSXNqXMmqspQ5z/EhzK44+os3NGdRN4Z4SXx4rosWQPxMETx5bKNWNZMM5aVc5REUX1Ne0YF4zpHMMT+4SNMhVZs6+eZ6s4E62qIMzzN43z+METx5bKNWNZMM5atFb)4WV1Ne0CNxMz+METx5bKNWNZMM5atFbDZSV1Ne05mqspQ5z/4SXqHWNrsSXIdqz6CcNAIFSrmKS+49bDM4SXNDnTNZSrxMr)m4XDNUTSs3NIQMz6CDTANYSrmKS+49bDQqn3VSrEtAMqVRETF7SWx3cymqspQ5z/MRXK+K2aM4EatFb)4WV1Ne05NZ3z+METxAmPshVEtWt+ZA5RMDrRV7ctFMsb+MV6d621wAVeQDEa+7N5ZSV1Ne0tt5NqVqzt+4SJH5AFsSXx+vs)45nqwArot5t1wMVwVFSAIFSrmKS+49bDQqnNMGXitAEatFb)4WV1Ne05NZ3z+METxAmPshVEM4JeH7NZE5bN4xctFMQc+MV6d621wAVeQDEaFcA4MRSDM3ToF3Qod3Svd6SAVhAaF7rxHvN)m42RHAN/F3sitq/RmMsK44V51RtIH7N545n3HWlKs5t1wM/Rmv2KN5AMMx41Q5/RZSVqMK2e1KQPxM3Rs6X3VStZmKS+ERN)s5aPHABRs3NGdRN4Z4SXx4BRtA4Z+M/DMRXKtMzaFGsIMRNZE6JPVRNEtWQaQvs)sAN1NR/R1RryFRNU+4Sq4ZmRs3N2xvNZEU4qsStZQKS1wM4S1xAWI4BKs6rqZ9b)xWsDM3TSsRrKw6NDFSSXx4rYsRtxFqzt+4Sq4ZmRs3NqQ6sDE3aPH5TeMZtIHhERZ4SXVRNetWtxMqETxWVqH6NEsWsyHSA2E6XqVGXEQKs2tMz6CqbWNDnaFGsIMRNZEUbRs3Tns6t+Z9pRmMbqN3zzNZ3z+METxWVqH6NEsKsZQvV4VU4DMGJo1RtxMqz6CDAWNDnaFGsIMRNZEUbRs3Tns6t+ZA5RmvSqN5ctFMsb+MV6d621VqTZsAEawRsDZhAqsSrEM4JeMRN)d4SXNq4TNZSrxvN4VWsDN6ziQKtIMcAZE5bKVSVas5t1wMz/4hz3VqctmKS+Eqr)45nN44Vn1qNeZUN)mFS1NefzFM+z+METxWVJHANEM44ZQFb5Q3n3HAVTF3Qo+3SvERSAIxAtsWtZHvtFEhzK44+os3NGdRN4Z4SXx4rCsRrMMqzt+4SqVSVTsSJeHhV44Y0DMSretWsbxMS6d6SAIxAtsWtZHvtFEhzK44+osSXx+vmTF7SxNDnTNZSrxvmDMRSDMSVeQDEa+YbDmSSXNKMzNZ3z+METxWVJHANEF6r2Mht5+Rz3xMzzmc/c1MMT1xAWI4BKF6rMZ5r)m4XDNUVosA4VxMStx5bRHANZFSSrxvmDMRSDMSVeQDEatFb)4WV1Ne0CNxMz+METxWVJHANEF6r2MhtF47AqIMzz43spHMMT+4SqHANe1KsyMqz6HhANwWNZmKS+VRNUF7SqVqAaMMNVQ5/RsAVDN5AaQKS1wvEDxUVqN7AtsWQqZAA4VAVRtMzzQKt++RNU+4SqVKNEMMNMQSA2EWVqHUTeF5t1wM4S1xAWI4roMMNxZAA4MR5PN6XE1qt1wMVwmSNWNDnaFGQaFebGEUARs3T6sq5axMz6CDXX4KVTNZSrxxNF43sDMGXiQc4xCRtFx6X3VDctFMspHMMT+4S3MSt6sSJeHhV44Y0DMSreQc4VxMS61RSAIxAtM44ZQFb5mSSXNqXMmqspQ5z/EhzK44+os3NGdRN4Z4SXx4rS1RrMEDN5Q4SWI4rCQqmqMcA2EWsNVK2YF3Qo+3Swd6SAIxAtM4XKMRNDE3nR4Z2asWS1wM4t1xAWI4rCQqmqMcA2EUMPHAmKF3QoQMMT1xAWI4rCQqmqMcA2EUMPs3TZF3QoN5V6d621wAtFs6Bq+vtFZ701Ne0MNZ3z+METxAmPsSAtFMspHMMT+4SJH5AFs3Nytvt5ZhA1NefzmqspQ5z/MRXK+K2aM4EaQ6N)s6A1Ne0Y43spHMMT+4SJH5AFs3NytvtFx6X3VDctFMsAFqV6d621wAVeQDEaQAAZEU4RH6EoQKS1w4t6d6SAIxAtF6r2Mht5+D0q4MctF4S+VDN4MDA1xxAtF6r2MhtF47ARHANEsUr+dDNUF7SWxGMzNZ3z+METxAmPshVEM4JeH7NZEUMPHAmKF3QoFq4S1xAWI4rM1RtKZAAFEhz3MK2CM44bxMS6VxAWNDnaF7rZQhVGE5bN44VTsSXIdqz6CDTX4DnTNZtnQ5z/4h5PHAmKsRrMw5z6H7s1VqA6Qc4ZN9bDZhz3NANEt6BaERNUF7S1VqAaQqN24AASFh21VqTZsAEaQYpR1cSXw5TSQRrVQ5/RZSVqMK2e1KsqZUN)EWVqN3zzFGsqQ6sDd5XJH5AFFSSrxvN4VWsDN5AtsAEaHxNFZhzqwWVtFxrItvV)Zv21VqTZsAEaQYpRs5nNVKNCs6tbxMS6VvSAIxAtsAMqVRt5m4SqMK2nMZsZw6N5VU41Ne0tt6rZFcASFh21VqTZsAEaVDN4MDADN55K1R+eQvsDsAV1NR/R1RryFRNU+4Sq4ZmRs3NqQ6sDE3aPH5TrsSXqQSAtF7SAtFSrmKS+ERN)s5nRVcVnQcMqtvt5x6XNN5ctFMspHMMT+4Sq4ZmRs3NiHhEDZSVNMK2rsc42FRNUF7SAIFSrmKS+ERN)s5nRVcVnQcMqtvtFx6X3VRVZF3QoQMMT1xAWI4BKs6rqZ6QRMRAK4ZNSsSXx+vN)VWV1Ne0CmqspQ5/RZSVqMK2PsRtIQvNDx5nNM3TMtA4VxMStx5bRHANZFSSrxvmDMRSDMGXiQc4xCRt5+RXJIMzzF4QKHMMT+4SqVSVTsSJeHhV44Y0DNUVitAS1wMVwmSNWNDnaFGsI4UNZEUARs3T6sq5a+7N5ZSV1Ne0tMMNZHvNUFh21VqTMtAEa+vsDZ3sRmZ2S1RrMEqz6CDAWNDnaFGsI4UNZEUARs3T6sq5aFcA4d4SXNebrmqspQ5/RZSN3MK2M1RtKZUN)mFS1Ne0yF4spHMMT+4SqVSVTsSXZQhVGEUXRH9StF4Snd3Svd6SAIxAtsWtZHvtFMRXK+K2Yt5NIMqz6CcSNNAVTs5t1Q5/RZSN3MK2M1RtKZA5RmvSqIMzzNZ3z+METxWVJHANEF6r2MhtF47AqIMzz43spHMMT+4SqHANe1KsyMqz6HGQPHUTCs5trxvmRZ4SXVRNetWtxMqETxWsqVW2etWtbxMS/Z74KH5caFGsqMRtFESVqH62tFxrItvV)Zv21VRNZsSXxHFbDE3nq4ZNa1R+KxMS6VvAWNDnaFGQaFebGEUARs3T6sq5aQ3z6CDXX4KVTNZSrxxNF43sDMGXiQc4xCRt5FSSXNqXMmqspQ5/RE5pP+K2rsRtINRs2EUMPHAmKF3Qo+MV6d621VK2C1DEa+vsDZ3sRmZ2S1RtIMqz6CqNWNDnaF7BeHhV44Y01NefzFM+z+METxUARs3T6sq5a+7N5ZSV1Ne0tsAMaM7NtFh21wAtFs6Bq+vt5sU43N6AtF4Sn45MT1xAWI4rCQqmqMcA2E903NU)KF3QotMV6d621wAtFs6Bq+vtFx6X3VDctFMspHMMT+4SNMhVZs6+eZA5RmvAqN3zz4S3z+METx5bKNWNZMM5aQxNSF7SXx7nTNZSrxMr)m4X1Ne0rmqspQ5z/MRXK+K2aM4EaERETF7SAxFSrmKS+49bDQqn3VSrEtAMqVRETF7SWxYbrmqspQ5z/MRXK+K2aM4EatFb)4WV1Ne0CNZ3z+METxAmPshVEtWt+ZA5RMDrRV7ctFMQP+MV6d621wAVeQDEa+7N5ZSV1Ne0tt5NqVqzt+4SJH5AFsSXx+vs)45nqwArot5t1wMVwVFSAIFSrmKS+49bDQqnNMGXitAEatFb)4WV1Ne0rmqspQ5z/MRXK+K2CM44ZHvtF47AqIMzzN4zpHMMT+4SJH5AFsSXx+vs)45nK4xttFMQc1MMT1xAEsh50JYaYQU0KwvNzdDTKJG/YFU4+QSA/F7SqN5ArF3Qod346d6SAIxAt1Dr++RV4VWs3MSr6sWmaH7mRZh/PN5AntAX1wMBTF7SAx3/zNZ3z+METxASNwWNns6rqdc5R4SVDNAVTsA4ZNebDZ70NNRzMF3Qo4At6ERSAIxAt1cX+dcAF4YfPHAVSs3NZHvN4MqQPs3ToMxrAwMBTF7SAx3/zNZ3z+METx5sNVK2CMMNeQhsDx5nRHAmKsRrxQhV4EU4NFRzMF3QoM34CNvSAIxAtsAMqVRN)45bRshNZs3NZHvN4MqQPs3ToMMsi1Mz6CDTANqXrmqspQ5/RZSVqVKNTMMNZN6mqE6z3VqTi1qN2QxNFF7SJN3zzN4zV45V6d621VRXoQc4YMqrD43n344VCQcsi1Mz6CDTAx7cTNZSrxvs4E6ARNWNMMxEaQ6sD4hAXwWVtFMsVMS+T1xAWI4ra1DEaH7mRZh/PN5AntAX1wMBTF7SAx3/zNZ3z+METx6lP+K2itWsIHYb5mvA3M3zzF5t1wMSwd6SAIxAttUrIVqS/EcSXxvASN4sNHMMT+4SKVKNat5NxHhEDMqnRHAmKsRrxQhV4EU4Xw5XtFMQctMSvd6SAIxAtQKQqQUN54hzKVSVEsRrMERs)4hXK4Z2SFxBKxMS6F3NAxFSrmKS+M7mqE623N6VosSXNwMBTF7SAx3/zN43z+METxAX3VW2at5NKdRtFMxSJN3zzN4zb+4+T1xAWI4rFtWma+7N5ZSVNVeSzFWS1wM4wF3NxxFSrmKS+M7mqEUX3N5TZMZQzwMrUF7SAx7cSNZ3z+MnbjZqYC9XqwxcSJG/nVKQTEZJqVZMnCG20"

if bs_v619 then
	bs_v638 = bs_decode_config(bs_v619)

	if bs_v638 then
		bs_v638.author = "bluesense"
		bs_v523[bs_v609] = bs_encode_config(bs_v638)
	end

	bs_v536[#bs_v536 + 1] = bs_v609
end

bs_v637 = {
	"\f<shield-halved>\r  anti-aim",
	"    \f<caret-right>\r  general",
	"    \f<caret-right>\r  builder",
	"    \f<caret-right>\r  defensive",
	"\f<eye>\r  visuals",
	"    \f<caret-right>\r  general",
	"    \f<caret-right>\r  ui",
	"\f<gears>\r  misc"
}
bs_v650 = {}

for iter_0_13, iter_0_14 in ipairs(bs_v637) do
	bs_v650[iter_0_14] = iter_0_13
end

bs_v658 = {
	{
		2,
		3,
		4
	},
	[5] = {
		6,
		7
	}
}
bs_v666 = {
	[2] = {
		{
			"antiaim",
			"general"
		}
	},
	[3] = {
		{
			"antiaim",
			"configure"
		},
		{
			"antiaim",
			"angles",
			"builder"
		},
		{
			"antiaim",
			"angles",
			"freestanding"
		}
	},
	[4] = {
		{
			"antiaim",
			"defensive"
		}
	},
	[6] = {
		{
			"info",
			"additions"
		},
		{
			"info",
			"scope_zoom"
		},
		{
			"info",
			"viewmodel"
		},
		{
			"info",
			"custom_scope"
		},
		{
			"visuals",
			"aspect_ratio"
		},
		{
			"visuals",
			"manual_arrows"
		},
		{
			"visuals",
			"silent_view"
		}
	},
	[7] = {
		{
			"info",
			"crosshair"
		},
		{
			"info",
			"lc_ind"
		},
		{
			"info",
			"velocity"
		},
		{
			"info",
			"abf_ind"
		},
		{
			"info",
			"def_ind"
		},
		{
			"info",
			"watermark"
		},
		{
			"info",
			"notify"
		},
		{
			"info",
			"hitmarker"
		},
		{
			"info",
			"side_ind"
		},
		{
			"info",
			"keybinds_ui"
		}
	},
	[8] = {
		{
			"misc",
			"aimbot"
		},
		{
			"misc",
			"movement"
		},
		{
			"misc",
			"animbreaker"
		},
		{
			"misc",
			"drink"
		},
		{
			"misc",
			"clantag"
		},
		{
			"misc",
			"killsay"
		}
	}
}
bs_v675 = {}

function bs_v682()
	local var_164_0 = bs_menu.info.presets.tabs
	local var_164_1 = var_164_0:get()

	if type(var_164_1) ~= "table" then
		var_164_1 = {}
	end

	local var_164_2 = {}

	for iter_164_0, iter_164_1 in ipairs(var_164_1) do
		var_164_2[type(iter_164_1) == "number" and iter_164_1 or bs_v650[iter_164_1] or 0] = true
	end

	local var_164_3 = {}

	for iter_164_2, iter_164_3 in ipairs(bs_v675) do
		var_164_3[iter_164_3] = true
	end

	for iter_164_4 in pairs(var_164_2) do
		if not var_164_3[iter_164_4] then
			if bs_v658[iter_164_4] then
				for iter_164_5, iter_164_6 in ipairs(bs_v658[iter_164_4]) do
					var_164_2[iter_164_6] = true
				end
			else
				for iter_164_7, iter_164_8 in pairs(bs_v658) do
					local var_164_4 = true

					for iter_164_9, iter_164_10 in ipairs(iter_164_8) do
						if not var_164_2[iter_164_10] then
							var_164_4 = false

							break
						end
					end

					if var_164_4 then
						var_164_2[iter_164_7] = true
					end
				end
			end
		end
	end

	for iter_164_11 in pairs(var_164_3) do
		if not var_164_2[iter_164_11] then
			if bs_v658[iter_164_11] then
				for iter_164_12, iter_164_13 in ipairs(bs_v658[iter_164_11]) do
					var_164_2[iter_164_13] = nil
				end
			else
				for iter_164_14, iter_164_15 in pairs(bs_v658) do
					for iter_164_16, iter_164_17 in ipairs(iter_164_15) do
						if iter_164_17 == iter_164_11 then
							var_164_2[iter_164_14] = nil

							break
						end
					end
				end
			end
		end
	end

	local var_164_5 = {}
	local var_164_6 = {}
	local var_164_7 = type(var_164_1[1]) == "string"

	for iter_164_18 = 1, 8 do
		if var_164_2[iter_164_18] then
			var_164_5[#var_164_5 + 1] = iter_164_18
			var_164_6[#var_164_6 + 1] = var_164_7 and bs_v637[iter_164_18] or iter_164_18
		end
	end

	var_164_0:set(var_164_6)

	bs_v675 = var_164_5
end

bs_menu.info.presets.tabs:set_callback(bs_v682, true)

function bs_get_cfg_data()
	local var_165_0 = bs_menu.info.presets.tabs:get()

	if type(var_165_0) ~= "table" or #var_165_0 == 0 then
		return nil, false
	end

	local var_165_1 = {}
	local var_165_2 = {}

	for iter_165_0, iter_165_1 in ipairs(var_165_0) do
		local var_165_3 = type(iter_165_1) == "number" and iter_165_1 or bs_v650[iter_165_1]
		local var_165_4 = var_165_3 and bs_v666[var_165_3] or nil

		if var_165_4 then
			for iter_165_2, iter_165_3 in ipairs(var_165_4) do
				local var_165_5 = table.concat(iter_165_3, "\x00")

				if not var_165_2[var_165_5] then
					var_165_2[var_165_5] = true
					var_165_1[#var_165_1 + 1] = iter_165_3
				end
			end
		end
	end

	return #var_165_1 > 0 and var_165_1 or nil, #var_165_1 > 0
end

function bs_encode_inner2(arg_166_0, arg_166_1)
	if not arg_166_1 then
		return true
	end

	if not arg_166_0 then
		return false
	end

	for iter_166_0, iter_166_1 in ipairs(arg_166_0) do
		if iter_166_1[1] == "info" or iter_166_1[1] == "visuals" then
			return true
		end
	end

	return false
end

function bs_v712(arg_167_0, arg_167_1)
	if not arg_167_0 then
		return false
	end

	for iter_167_0, iter_167_1 in ipairs(arg_167_0) do
		if iter_167_1[1] == arg_167_1 then
			return true
		end
	end

	return false
end

function bs_cfg_has_key(arg_168_0, arg_168_1)
	if not arg_168_0 then
		return false
	end

	for iter_168_0, iter_168_1 in ipairs(arg_168_0) do
		local var_168_0 = true

		for iter_168_2, iter_168_3 in ipairs(arg_168_1) do
			if iter_168_1[iter_168_2] ~= iter_168_3 then
				var_168_0 = false

				break
			end
		end

		if var_168_0 then
			return true
		end
	end

	return false
end

function bs_v736(arg_169_0, arg_169_1)
	if not arg_169_0 then
		return false
	end

	for iter_169_0, iter_169_1 in ipairs(arg_169_0) do
		if iter_169_1[1] == arg_169_1 and #iter_169_1 > 1 then
			return true
		end
	end

	return false
end

function bs_v749(arg_170_0, arg_170_1)
	if arg_170_1 == false then
		return arg_170_0
	end

	pcall(function()
		local var_171_0 = bs_v479:get()

		arg_170_0.__theme_r = var_171_0.r
		arg_170_0.__theme_g = var_171_0.g
		arg_170_0.__theme_b = var_171_0.b
		arg_170_0.__theme_a = var_171_0.a
		arg_170_0.__theme_share_logo = bs_v480:get()
	end)
	pcall(function()
		local var_172_0 = {}

		for iter_172_0, iter_172_1 in ipairs(ui.get_binds()) do
			if iter_172_1.value and iter_172_1.value > 0 then
				var_172_0[iter_172_1.name] = iter_172_1.value
			end
		end

		arg_170_0.__binds = var_172_0
	end)
	pcall(function()
		local var_173_0 = bs_ui_elements
		local var_173_1 = var_173_0._select

		if not var_173_1 then
			return
		end

		local var_173_2 = {
			"double tap",
			"hide shots",
			"freestanding",
			"fake duck",
			"min damage",
			"dormant aimbot",
			"lc",
			"ping"
		}
		local var_173_3 = {}

		for iter_173_0, iter_173_1 in ipairs(var_173_2) do
			local var_173_4, var_173_5 = pcall(function()
				return var_173_1:get(iter_173_1)
			end)

			if var_173_4 and var_173_5 then
				var_173_3[#var_173_3 + 1] = iter_173_1
			end
		end

		local var_173_6 = {
			selected = var_173_3
		}

		pcall(function()
			var_173_6.enabled = var_173_0._label:get()
		end)

		local function var_173_7(arg_176_0, arg_176_1)
			if arg_176_1 and arg_176_1.get then
				local var_176_0, var_176_1 = pcall(function()
					return arg_176_1:get()
				end)

				if var_176_0 and var_176_1 then
					var_173_6[arg_176_0] = {
						var_176_1.r,
						var_176_1.g,
						var_176_1.b,
						var_176_1.a
					}
				end
			end
		end

		var_173_7("bg", var_173_0.col_bg)
		var_173_7("col_dt_on", var_173_0.col_dt_on)
		var_173_7("col_dt_off", var_173_0.col_dt_off)
		var_173_7("col_hs_on", var_173_0.col_hs_on)
		var_173_7("col_fs_on", var_173_0.col_fs_on)
		var_173_7("col_fd_on", var_173_0.col_fd_on)
		var_173_7("col_da_on", var_173_0.col_da_on)
		var_173_7("col_dmg_on", var_173_0.col_dmg_on)
		var_173_7("col_lc_on", var_173_0.col_lc_on)
		var_173_7("col_lc_bad", var_173_0.col_lc_bad)
		var_173_7("col_ping_on", var_173_0.col_ping_on)
		pcall(function()
			var_173_6.blur = var_173_0.blur:get()
		end)
		pcall(function()
			var_173_6.font = var_173_0.font:get()
		end)

		arg_170_0.__ind_state = var_173_6
	end)

	return arg_170_0
end

function bs_encode_inner(arg_180_0, arg_180_1)
	local var_180_0 = true

	if arg_180_0 and #arg_180_0 > 0 then
		return bs_v749(bs_pui.save(unpack(arg_180_0)), var_180_0)
	end

	return bs_v749(bs_pui.save(), var_180_0)
end

function bs_v759()
	return bs_v749(bs_pui.save())
end

function bs_v5(arg_182_0, arg_182_1)
	if type(arg_182_0) ~= "table" then
		return
	end

	if arg_182_1 and #arg_182_1 > 0 then
		pcall(function()
			bs_pui.load(arg_182_0, false, unpack(arg_182_1))
		end)
	else
		pcall(function()
			bs_pui.load(arg_182_0)
		end)
	end

	pcall(function()
		if arg_182_0.__theme_r then
			bs_v479:set(color(arg_182_0.__theme_r, arg_182_0.__theme_g, arg_182_0.__theme_b, arg_182_0.__theme_a or 255))
		end

		if arg_182_0.__theme_share_logo ~= nil then
			bs_v480:set(arg_182_0.__theme_share_logo)
		end
	end)
	pcall(function()
		local var_186_0 = arg_182_0.__binds

		if not var_186_0 then
			return
		end

		local var_186_1 = {
			["ai peek"] = bs_menu.antiaim and bs_menu.antiaim.general and bs_menu.antiaim.general.aipeek and bs_menu.antiaim.general.aipeek.switch,
			freestanding = bs_menu.antiaim and bs_menu.antiaim.general and bs_menu.antiaim.general.freestanding and bs_menu.antiaim.general.freestanding.switch
		}

		for iter_186_0, iter_186_1 in pairs(var_186_0) do
			local var_186_2 = var_186_1[iter_186_0]

			if var_186_2 then
				pcall(function()
					var_186_2:set_bind(iter_186_1)
				end)
			end
		end
	end)
	pcall(function()
		local var_188_0 = arg_182_0.__ind_state

		if not var_188_0 then
			return
		end

		local var_188_1 = bs_ui_elements
		local var_188_2 = var_188_1._select

		if var_188_0.selected and var_188_2 then
			pcall(function()
				var_188_2:set(var_188_0.selected)
			end)
		end

		if var_188_0.enabled ~= nil then
			pcall(function()
				var_188_1._label:set(var_188_0.enabled)
			end)
		end

		local function var_188_3(arg_191_0, arg_191_1)
			if var_188_0[arg_191_0] and arg_191_1 and arg_191_1.set then
				local var_191_0 = var_188_0[arg_191_0]

				pcall(function()
					arg_191_1:set(color(var_191_0[1], var_191_0[2], var_191_0[3], var_191_0[4]))
				end)
			end
		end

		var_188_3("bg", var_188_1.col_bg)
		var_188_3("col_dt_on", var_188_1.col_dt_on)
		var_188_3("col_dt_off", var_188_1.col_dt_off)
		var_188_3("col_hs_on", var_188_1.col_hs_on)
		var_188_3("col_fs_on", var_188_1.col_fs_on)
		var_188_3("col_fd_on", var_188_1.col_fd_on)
		var_188_3("col_da_on", var_188_1.col_da_on)
		var_188_3("col_dmg_on", var_188_1.col_dmg_on)
		var_188_3("col_lc_on", var_188_1.col_lc_on)
		var_188_3("col_lc_bad", var_188_1.col_lc_bad)
		var_188_3("col_ping_on", var_188_1.col_ping_on)

		if var_188_0.blur ~= nil then
			pcall(function()
				var_188_1.blur:set(var_188_0.blur)
			end)
		end

		if var_188_0.font ~= nil then
			pcall(function()
				var_188_1.font:set(var_188_0.font)
			end)
		end
	end)
end

function bs_v19()
	local var_195_0 = bs_menu.info.presets.name:get()

	if not var_195_0 then
		return
	end

	local var_195_1 = bs_v523[var_195_0]

	if not var_195_1 then
		return
	end

	local var_195_2 = bs_decode_config(var_195_1)

	if var_195_2 then
		local var_195_3

		var_195_3 = (var_195_0 == bs_v609 or var_195_0 == "default") and "bluesense" or var_195_2.author
	end
end

function bs_v32()
	local var_196_0 = {}

	for iter_196_0, iter_196_1 in ipairs(bs_v536) do
		var_196_0[#var_196_0 + 1] = iter_196_1
	end

	for iter_196_2, iter_196_3 in pairs(bs_v523) do
		local var_196_1 = false

		for iter_196_4, iter_196_5 in ipairs(var_196_0) do
			if iter_196_5 == iter_196_2 then
				var_196_1 = true

				break
			end
		end

		if not var_196_1 then
			var_196_0[#var_196_0 + 1] = iter_196_2
		end
	end

	bs_menu.info.presets.list:update(var_196_0)

	local var_196_2 = bs_menu.info.presets.list
	local var_196_3 = var_196_2:list()[var_196_2:get()]

	if not var_196_3 then
		return
	end

	if var_196_3 ~= bs_v533 then
		bs_menu.info.presets.name:set(var_196_3)
		bs_v19()
	end

	local var_196_4 = false

	for iter_196_6, iter_196_7 in ipairs(bs_v536) do
		if iter_196_7 == var_196_3 then
			var_196_4 = true

			break
		end
	end

	bs_menu.info.presets.save:disabled(var_196_4)
	bs_menu.info.presets.export:disabled(false)
	bs_menu.info.presets.delete:disabled(var_196_4)
	bs_menu.info.presets.create:disabled(not var_196_4)
end

function bs_v46(arg_197_0, arg_197_1)
	bs_v523[arg_197_0] = arg_197_1

	bs_v540()
	bs_v32()
end

function bs_v61()
	local var_198_0 = bs_menu.info.presets.name:get()

	if not var_198_0 or var_198_0:gsub(" ", "") == "" then
		bs_notify.new({
			"invalid name"
		})

		return
	end

	if var_198_0 == bs_v533 then
		return
	end

	local var_198_1 = bs_v523[var_198_0]

	if not var_198_1 then
		bs_notify.new({
			"config not found"
		})

		return
	end

	local var_198_2 = bs_decode_config(var_198_1)
	local var_198_3 = var_198_2 and bs_decode_config(var_198_2.config) or nil

	if not var_198_3 then
		bs_notify.new({
			"corrupt config"
		})

		return
	end

	local var_198_4, var_198_5 = bs_get_cfg_data()

	bs_v5(var_198_3, var_198_4)

	if var_198_2.positions and bs_encode_inner2(var_198_4, var_198_5) then
		local var_198_6, var_198_7 = pcall(bs_decode_config, var_198_2.positions)

		if var_198_6 and var_198_7 then
			bs_apply_positions(var_198_7)
		end
	end

	if var_198_2.builder and bs_v500 then
		local var_198_8, var_198_9 = pcall(bs_decode_config, var_198_2.builder)

		if var_198_8 and var_198_9 then
			pcall(bs_v500, var_198_9)
		end
	end

	if var_198_2.defensive and bs_v509 then
		local var_198_10, var_198_11 = pcall(bs_decode_config, var_198_2.defensive)

		if var_198_10 and var_198_11 then
			pcall(bs_v509, var_198_11)
		end
	end

	bs_logger:message(("loaded %s · %s"):format(var_198_2.author, var_198_0))
	bs_notify.new({
		"loaded  ",
		var_198_0
	})
end

function bs_get_author()
	local var_199_0, var_199_1 = pcall(function()
		return common.get_username()
	end)

	return var_199_0 and var_199_1 and var_199_1 ~= "" and var_199_1 or ""
end

function bs_v91()
	local var_201_0 = bs_menu.info.presets.name:get()

	if not var_201_0 or var_201_0:gsub(" ", "") == "" then
		bs_notify.new({
			"name cannot be empty"
		})

		return
	end

	if var_201_0 == bs_v533 then
		return
	end

	local var_201_1 = false

	for iter_201_0, iter_201_1 in ipairs(bs_v536) do
		if iter_201_1 == var_201_0 then
			var_201_1 = true

			break
		end
	end

	if var_201_1 then
		bs_notify.new({
			"enter a new name to create config"
		})

		return
	end

	local var_201_2 = bs_v759()
	local var_201_3 = bs_encode_config(bs_v593())
	local var_201_4 = bs_get_builder and bs_encode_config(bs_get_builder()) or nil
	local var_201_5 = bs_get_defensive and bs_encode_config(bs_get_defensive()) or nil

	if bs_v523[var_201_0] then
		local var_201_6 = bs_decode_config(bs_v523[var_201_0])

		var_201_6.config = bs_encode_config(var_201_2)
		var_201_6.positions = var_201_3

		if var_201_4 then
			var_201_6.builder = var_201_4
		end

		if var_201_5 then
			var_201_6.defensive = var_201_5
		end

		bs_v46(var_201_0, bs_encode_config(var_201_6))
	else
		local var_201_7 = {
			config = bs_encode_config(var_201_2),
			positions = var_201_3,
			author = common.get_username(),
			time = common.get_unixtime()
		}

		if var_201_4 then
			var_201_7.builder = var_201_4
		end

		if var_201_5 then
			var_201_7.defensive = var_201_5
		end

		bs_v46(var_201_0, bs_encode_config(var_201_7))
	end

	bs_notify.new({
		"saved  ",
		var_201_0
	})
end

function bs_v106()
	local var_202_0 = bs_menu.info.presets.name:get()

	if not var_202_0 or var_202_0:gsub(" ", "") == "" then
		bs_notify.new({
			"enter a name first"
		})

		return
	end

	if var_202_0 == bs_v533 then
		return
	end

	local var_202_1 = false

	for iter_202_0, iter_202_1 in ipairs(bs_v536) do
		if iter_202_1 == var_202_0 then
			var_202_1 = true

			break
		end
	end

	if var_202_1 then
		bs_notify.new({
			"cannot overwrite default"
		})

		return
	end

	if bs_v523[var_202_0] then
		bs_notify.new({
			"config already exists"
		})

		return
	end

	local var_202_2 = bs_v759()
	local var_202_3 = bs_encode_config(bs_v593())
	local var_202_4 = {
		config = bs_encode_config(var_202_2),
		positions = var_202_3,
		author = bs_get_author(),
		time = common.get_unixtime()
	}

	if bs_get_builder then
		local var_202_5 = bs_get_builder()

		if var_202_5 then
			var_202_4.builder = bs_encode_config(var_202_5)
		end
	end

	if bs_get_defensive then
		local var_202_6 = bs_get_defensive()

		if var_202_6 then
			var_202_4.defensive = bs_encode_config(var_202_6)
		end
	end

	bs_v46(var_202_0, bs_encode_config(var_202_4))
	bs_v19()
	bs_notify.new({
		"created  ",
		var_202_0
	})
end

bs_v122 = nil

function bs_v139(arg_203_0)
	local var_203_0 = bs_menu.info.presets

	if arg_203_0 == "normal" then
		var_203_0.list:disabled(false)
		var_203_0.name:disabled(false)
		var_203_0.tabs:visibility(false)
		var_203_0.load:visibility(true)
		var_203_0.save:visibility(true)
		var_203_0.create:visibility(true)
		var_203_0.delete:visibility(true)
		var_203_0.import:visibility(true)
		var_203_0.export:visibility(true)
		var_203_0.cancel:visibility(false)
		var_203_0.confirm:visibility(false)
		bs_v32()
	else
		var_203_0.list:disabled(true)
		var_203_0.name:disabled(true)
		var_203_0.tabs:visibility(true)
		var_203_0.load:visibility(false)
		var_203_0.save:visibility(false)
		var_203_0.create:visibility(false)
		var_203_0.delete:visibility(false)
		var_203_0.import:visibility(false)
		var_203_0.export:visibility(false)
		var_203_0.cancel:visibility(true)
		var_203_0.confirm:visibility(true)
	end
end

function bs_v157()
	bs_v122 = "export"

	bs_v139("export")
end

function bs_v182()
	local var_205_0 = bs_clipboard.get()

	if not var_205_0 or var_205_0:gsub(" ", "") == "" then
		bs_notify.new({
			"clipboard is empty"
		})

		return
	end

	bs_v122 = "import"

	bs_v139("import")
end

function bs_v205()
	bs_v122 = nil

	bs_v139("normal")
end

function bs_v223()
	function bs_v869(arg_208_0, arg_208_1)
		local var_208_0 = arg_208_1 and "\a99FF99FF[ + ]" or "\aFF4D4DFF[ x ]"
		local var_208_1 = arg_208_1 and "\a99FF99FF" or "\a808080FF"

		return string.format("  %s %s%s\aDEFAULT", var_208_0, var_208_1, arg_208_0)
	end

	if bs_v122 == "export" then
		bs_v871, bs_v886 = bs_get_cfg_data()
		bs_v888 = not bs_v886 or bs_cfg_has_key(bs_v871, {
			"antiaim",
			"general"
		})
		bs_v890 = not bs_v886 or bs_cfg_has_key(bs_v871, {
			"antiaim",
			"configure"
		})
		bs_v892 = not bs_v886 or bs_cfg_has_key(bs_v871, {
			"antiaim",
			"defensive"
		})
		bs_v894 = not bs_v886 or bs_cfg_has_key(bs_v871, {
			"info",
			"additions"
		})
		bs_v896 = not bs_v886 or bs_cfg_has_key(bs_v871, {
			"info",
			"lc_ind"
		}) or bs_cfg_has_key(bs_v871, {
			"info",
			"side_ind"
		}) or bs_cfg_has_key(bs_v871, {
			"info",
			"crosshair"
		})
		bs_v898 = not bs_v886 or bs_cfg_has_key(bs_v871, {
			"misc",
			"aimbot"
		})
		bs_v901 = bs_encode_inner2(bs_v871, bs_v886)
		bs_v874 = {
			config = bs_encode_config(bs_encode_inner(bs_v871, bs_v886)),
			author = bs_get_author(),
			time = common.get_unixtime()
		}
		bs_v878 = {
			aa_gen = bs_v888,
			vis_gen = bs_v894,
			misc = bs_v898,
			indicators = bs_v896
		}

		if bs_v890 and bs_get_builder then
			bs_v884 = bs_get_builder()

			if bs_v884 then
				bs_v874.builder = bs_encode_config(bs_v884)
				bs_v878.builder = true
			end
		end

		if bs_v892 and bs_get_defensive then
			bs_v883 = bs_get_defensive()

			if bs_v883 then
				bs_v874.defensive = bs_encode_config(bs_v883)
				bs_v878.defensive = true
			end
		end

		if bs_v901 then
			bs_v874.positions = bs_encode_config(bs_v593())
			bs_v878.positions = true
		end

		if bs_v896 then
			pcall(function()
				local var_209_0 = serialize_ind_state()

				if var_209_0 then
					bs_v874.ind_state = bs_encode_config(var_209_0)
					bs_v878.indicators = true
				end
			end)
		end

		pcall(function()
			bs_clipboard.set(bs_encode_config(bs_v874))
		end)

		bs_v882 = ((((("exported settings:\n" .. bs_v869("anti-aim -> general", bs_v878.aa_gen) .. "\n") .. bs_v869("anti-aim -> builder", bs_v878.builder) .. "\n") .. bs_v869("anti-aim -> defensive", bs_v878.defensive) .. "\n") .. bs_v869("visuals -> general", bs_v878.vis_gen) .. "\n") .. bs_v869("visuals -> ui", bs_v878.indicators) .. "\n") .. bs_v869("misc", bs_v878.misc)

		bs_logger:message(bs_v882)
		bs_notify.new({
			"copied settings"
		})
	elseif bs_v122 == "import" then
		bs_v870 = bs_clipboard.get()

		if not bs_v870 or bs_v870:gsub(" ", "") == "" then
			bs_notify.new({
				"clipboard is empty"
			})

			return
		end

		bs_v885, bs_v887 = bs_get_cfg_data()
		bs_v889 = bs_decode_config(bs_v870)

		if not bs_v889 or not bs_v889.config then
			bs_notify.new({
				"invalid config data"
			})

			return
		end

		bs_v891 = bs_decode_config(bs_v889.config)

		if not bs_v891 then
			bs_notify.new({
				"corrupt config"
			})

			return
		end

		bs_v893 = {}

		function bs_v895(arg_211_0, arg_211_1)
			for iter_211_0 in pairs(arg_211_0) do
				if iter_211_0:sub(1, #arg_211_1) == arg_211_1 then
					return true
				end
			end

			return false
		end

		bs_v5(bs_v891, bs_v885)

		bs_v893.aa_gen = (not bs_v887 or bs_cfg_has_key(bs_v885, {
			"antiaim",
			"general"
		})) and bs_v895(bs_v891, "antiaim")
		bs_v893.vis_gen = (not bs_v887 or bs_cfg_has_key(bs_v885, {
			"info",
			"additions"
		})) and (bs_v895(bs_v891, "info") or bs_v895(bs_v891, "visuals"))
		bs_v893.misc = (not bs_v887 or bs_cfg_has_key(bs_v885, {
			"misc",
			"aimbot"
		})) and bs_v895(bs_v891, "misc")

		if bs_v889.positions and bs_encode_inner2(bs_v885, bs_v887) then
			bs_v897, bs_v900 = pcall(bs_decode_config, bs_v889.positions)

			if bs_v897 and bs_v900 then
				bs_apply_positions(bs_v900)
			end
		end

		if not bs_v887 or bs_v712(bs_v885, "antiaim") then
			bs_v899 = not bs_v887 or bs_cfg_has_key(bs_v885, {
				"antiaim",
				"configure"
			})
			bs_v873 = not bs_v887 or bs_cfg_has_key(bs_v885, {
				"antiaim",
				"defensive"
			})

			if bs_v899 and bs_v889.builder and bs_v500 then
				bs_v877, bs_v881 = pcall(bs_decode_config, bs_v889.builder)

				if bs_v877 and bs_v881 then
					pcall(bs_v500, bs_v881)

					bs_v893.builder = true
				end
			end

			if bs_v873 and bs_v889.defensive and bs_v509 then
				bs_v876, bs_v880 = pcall(bs_decode_config, bs_v889.defensive)

				if bs_v876 and bs_v880 then
					pcall(bs_v509, bs_v880)

					bs_v893.defensive = true
				end
			end
		end

		if (not bs_v887 or bs_v712(bs_v885, "visuals")) and (not bs_v887 or bs_cfg_has_key(bs_v885, {
			"info",
			"lc_ind"
		}) or bs_cfg_has_key(bs_v885, {
			"info",
			"side_ind"
		}) or bs_cfg_has_key(bs_v885, {
			"info",
			"crosshair"
		})) and bs_v889.ind_state then
			bs_v875, bs_v879 = pcall(bs_decode_config, bs_v889.ind_state)

			if bs_v875 and bs_v879 then
				pcall(deserialize_ind_state, bs_v879)

				bs_v893.indicators = true
			end
		end

		bs_v872 = ((((("imported settings:\n" .. bs_v869("anti-aim -> general", bs_v893.aa_gen) .. "\n") .. bs_v869("anti-aim -> builder", bs_v893.builder) .. "\n") .. bs_v869("anti-aim -> defensive", bs_v893.defensive) .. "\n") .. bs_v869("visuals -> general", bs_v893.vis_gen) .. "\n") .. bs_v869("visuals -> ui", bs_v893.indicators) .. "\n") .. bs_v869("misc", bs_v893.misc)

		bs_logger:message(bs_v872)
		bs_notify.new({
			"imported settings"
		})
	end

	bs_v122 = nil

	bs_v139("normal")
end

function bs_v243()
	local var_212_0 = bs_menu.info.presets.name:get()

	if not var_212_0 or var_212_0:gsub(" ", "") == "" then
		return
	end

	if var_212_0 == bs_v533 then
		return
	end

	if not bs_v523[var_212_0] then
		return
	end

	bs_logger:message(("deleted %s"):format(var_212_0))
	bs_notify.new({
		"deleted  ",
		var_212_0
	})
	bs_v46(var_212_0, nil)
end

bs_menu.info.presets.load:set_callback(bs_v61)
bs_menu.info.presets.save:set_callback(bs_v91)
bs_menu.info.presets.create:set_callback(bs_v106)
bs_menu.info.presets.export:set_callback(bs_v157)
bs_menu.info.presets.import:set_callback(bs_v182)
bs_menu.info.presets.cancel:set_callback(bs_v205)
bs_menu.info.presets.confirm:set_callback(bs_v223)
bs_menu.info.presets.delete:set_callback(bs_v243)
bs_menu.info.presets.list:set_callback(bs_v32, true)
events.shutdown(bs_v540)
bs_v540()

bs_get_state = {}
bs_v522 = 0
bs_v522_last_tick = 0
bs_v527 = 2
events.createmove(function(arg_213_0)
	bs_v532 = arg_213_0 and arg_213_0.in_jump or false
end)

-- #############################################################################
-- #  [SEC-06] ANTI-AIM BUILDER - STATE ACCESSORS
-- #############################################################################
function bs_get_state.get(arg_214_0)
	local var_214_0 = entity.get_local_player()

	if var_214_0 == nil or not var_214_0:is_alive() then
		bs_v522 = 0

		return
	end

	if var_214_0:get_anim_state() == nil then
		return
	end

	local var_214_1 = var_214_0.m_flDuckAmount
	local var_214_2 = var_214_0.m_vecVelocity:length2d()
	local var_214_3 = not bs_v532 and bit.band(var_214_0.m_fFlags or 0, 1) == 1
	local var_214_4 = bs_menu.antiaim.angles.builder["legit aa"]

	if arg_214_0 and var_214_4 and var_214_4.allow_state:get() then
		bs_v522 = 0
		return "legit aa"
	end

	local var_214_5 = false
	local var_214_6 = false
	local var_214_7 = false
	local var_214_8 = false

	pcall(function()
		var_214_5 = bs_config.rage.main.double_tap:get()
	end)
	pcall(function()
		var_214_6 = bs_config.rage.main.hide_shots:get()
	end)
	pcall(function()
		var_214_7 = bs_config.antiaim.fake_lag.enabled_pui:get()
	end)
	pcall(function()
		local fakelag_state = bs_menu.antiaim.angles.builder["fakelag"]

		var_214_8 = fakelag_state and fakelag_state.allow_state:get() == true
	end)

	if var_214_7 and var_214_8 and not var_214_5 and not var_214_6 and var_214_2 > 1.11 then
		bs_v522 = 0
		return "fakelag"
	end

	if var_214_3 then
		bs_v522 = 0

		if bs_config.antiaim.misc.slow_walk:get() and var_214_2 > 1.11 and var_214_1 <= 0.5 then
			return "slowing"
		end

		if var_214_1 > 0.5 then
			local state = var_214_2 > 1.11 and "sneaking" or "crouching"
			return state
		end

		local state = var_214_2 > 1.11 and "running" or "standing"
		return state
	end

	local current_tick = globals.tickcount
	if current_tick ~= bs_v522_last_tick then
		bs_v522 = bs_v522 + 1
		bs_v522_last_tick = current_tick
	end

	if bs_v522 < bs_v527 then
		if var_214_1 > 0.5 then
			local state = var_214_2 > 1.11 and "sneaking" or "crouching"
			return state
		end

		local state = var_214_2 > 1.11 and "running" or "standing"
		return state
	end

	local state = var_214_1 > 0.5 and "air crouching" or "air"
	return state
end

function bs_get_state.visual(arg_218_0)
	local var_218_0 = entity.get_local_player()

	if var_218_0 == nil or not var_218_0:is_alive() then
		return
	end

	local var_218_1 = var_218_0.m_flDuckAmount or 0
	local var_218_2 = var_218_0.m_vecVelocity or vector(0, 0, 0)
	local var_218_3 = var_218_2.length2d and var_218_2:length2d() or math.sqrt((var_218_2.x or 0) * (var_218_2.x or 0) + (var_218_2.y or 0) * (var_218_2.y or 0))
	local var_218_4 = not bs_v532 and bit.band(var_218_0.m_fFlags or 0, 1) == 1
	local var_218_5 = bs_menu.antiaim.angles.builder["legit aa"]

	if arg_218_0 and var_218_5 and var_218_5.allow_state:get() then
		return "legit aa"
	end

	if var_218_4 then
		if bs_config.antiaim.misc.slow_walk:get() and var_218_3 > 1.11 and var_218_1 <= 0.5 then
			return "slowing"
		end

		if var_218_1 > 0.5 then
			return var_218_3 > 1.11 and "sneaking" or "crouching"
		end

		return var_218_3 > 1.11 and "running" or "standing"
	end

	return var_218_1 > 0.5 and "air crouching" or "air"
end

bs_manual_yaw = {
	think = function()
		local var_219_0 = bs_menu.antiaim.general.manual_yaw

		if bs_hotkeys:is_active("key left") then
			return true, -90
		end

		if bs_hotkeys:is_active("key right") then
			return true, 90
		end

		if bs_hotkeys:is_active("key forward") then
			return true, 180
		end

		if bs_hotkeys:is_active("key back") then
			return true, 0
		end

		local var_219_1 = var_219_0.select:get()

		if var_219_1 == "disabled" then
			return false, 0
		end

		local var_219_2 = ({
			left = -90,
			back = 0,
			forward = 180,
			right = 90
		})[var_219_1:lower()]

		if not var_219_2 then
			return false, 0
		end

		return true, var_219_2
	end
}

-- Manual yaw: while the manual yaw key is held, forces the real angle to "backward"
-- with the configured offset. Optionally locks the yaw modifier to a static 60/60
-- limit and applies the inverter.
-- #############################################################################
-- #  [SEC-07] MANUAL YAW
-- #############################################################################
function bs_manual_yaw.update(_cmd, state, _state_idx)
	local is_active, yaw_offset = bs_manual_yaw.think()
	local use_static = bs_menu.antiaim.general.manual_yaw.static:get()
	local inverter = bs_menu.antiaim.general.manual_yaw.inverter:get()
	local force_static = bs_menu.antiaim.general.manual_yaw.force_static and bs_menu.antiaim.general.manual_yaw.force_static:get()
	local base = bs_menu.antiaim.general.manual_yaw.base and bs_menu.antiaim.general.manual_yaw.base:get() or "at target"

	if is_active then
		state.yaw = "backward"
		state.yaw_base = base == "local view" and "Local View" or "At Target"
		state.yaw_offset = yaw_offset
		state.freestanding = false
		state.body_freestanding = false

		if force_static then
			state.yaw_modifier = "Disabled"
			state.modifier_offset = 0
			state.body_yaw = true
			state.body_yaw_options = {}
			state.left_limit = 60
			state.right_limit = 60
			state.freestand_peek = "off"
		end

		if use_static then
			state.inverter = inverter
		end
	end
end

bs_freestanding = {}
bs_safe_head = {}
	bs_safe_head.active = false
	bs_safe_head.last_log_target = nil
	bs_safe_head.last_log_time = 0

-- Per-state safe-head profiles: pitch / yaw offset / desync limit.
-- Safe head only triggers in: standing, air, air crouching, crouching, sneaking
-- (see bs_safe_head.think for the per-state gating). running / slowing are
-- excluded by the state gate and never reach this table.
bs_safe_head.profiles = {
	standing          = { pitch = "Down", yaw_offset = -2, limit = 50 },
	air               = { pitch = "Down", yaw_offset = 0, limit = 58 },
	["air crouching"] = { pitch = "Down", yaw_offset = 8, limit = 58 },
	crouching         = { pitch = "Down", yaw_offset = -2, limit = 50 },
	sneaking          = { pitch = "Down", yaw_offset = 4, limit = 58 },
}
bs_v535 = {
	[1] = "pistols",
	[9] = "grenades"
}
bs_v539 = {
	CWeaponSSG08 = 1,
	CKnife = 7,
	pistols = 6,
	CWeaponTec9 = 5,
	CWeaponSCAR20 = 4,
	CWeaponG3SG1 = 3,
	CWeaponAWP = 2
}
bs_v546 = {
	terrorist = {
		standing = {
			-2,
			-2,
			-6.4,
			-2,
			4.2,
			12,
			15
		},
		crouching = {
			2.4,
			2.4,
			2.4,
			2.4,
			-13,
			-13,
			-12
		},
		sneaking = {
			2.4,
			2.4,
			2.4,
			2.4,
			-9.3,
			-8,
			-9
		},
		["air crouching"] = {
			7.5,
			7.5,
			6,
			7,
			-3.5,
			-3.5,
			-15
		},
		air = {
			14,
			14,
			14,
			14,
			12,
			17,
			14
		}
	},
	counter_terrorist = {
		standing = {
			-3.6,
			-3.6,
			-4,
			-4,
			5.2,
			13,
			12
		},
		crouching = {
			-1,
			-1,
			4,
			0.2,
			-11,
			-8.5,
			-6
		},
		sneaking = {
			-1.6,
			-1.6,
			4.3,
			0,
			-7,
			-5,
			-14
		},
		["air crouching"] = {
			10,
			10,
			7,
			7,
			2,
			2,
			-12
		},
		air = {
			14,
			14,
			14,
			14,
			12,
			17,
			14
		}
	}
}
bs_v554 = {
	terrorist = {
		air = 17,
		["air crouching"] = 11,
		sneaking = 16,
		crouching = 23,
		standing = 23
	},
	counter_terrorist = {
		air = 23,
		["air crouching"] = 14,
		sneaking = 30,
		crouching = 35,
		standing = 35
	}
}
bs_v562 = {
	terrorist = {
		air = 43,
		["air crouching"] = 28,
		sneaking = 39,
		crouching = 41,
		standing = 63
	},
	counter_terrorist = {
		air = 65,
		["air crouching"] = 55,
		sneaking = 42,
		crouching = 44,
		standing = 61
	}
}

-- #############################################################################
-- #  [SEC-08] MOVEMENT STATE DETECTION
-- #############################################################################
function bs_detect_state(arg_221_0, arg_221_1)
	if not arg_221_1 or not arg_221_1:is_alive() then
		return nil
	end

	local var_221_0 = arg_221_1.m_vecVelocity and arg_221_1.m_vecVelocity:length2d() or 0
	local var_221_1 = (not arg_221_0 or not arg_221_0.in_jump) and bit.band(arg_221_1.m_fFlags or 0, 1) == 1
	local var_221_2 = var_221_1 and (arg_221_1.m_flDuckAmount or 0) > 0.5
	local var_221_3 = false
	local var_221_4 = false

	pcall(function()
		var_221_3 = var_221_1 and bs_config.antiaim.misc.fake_duck:get()
	end)
	pcall(function()
		var_221_4 = var_221_1 and var_221_0 > 1.11 and not var_221_2 and bs_config.antiaim.misc.slow_walk:get()
	end)

	if not var_221_1 then
		return (arg_221_0 and arg_221_0.in_duck or (arg_221_1.m_flDuckAmount or 0) > 0.5) and "air crouching" or "air"
	elseif var_221_2 or var_221_3 then
		return var_221_0 > 1.11 and "sneaking" or "crouching"
	elseif var_221_4 then
		return "slowing"
	elseif var_221_0 > 1.11 then
		return "running"
	end

	return "standing"
end

-- Trace-bullet head visibility: true when the threat has line-of-fire to our head.
-- Fails open (returns true) if the trace API is unavailable or errors, so a missing
-- trace never silently disables safe head.
-- #############################################################################
-- #  [SEC-09] SAFE HEAD
-- #############################################################################
function bs_safe_head.threat_can_hit_head(threat)
	local me = entity.get_local_player()

	if not threat or not me then
		return true
	end

	local enemy_eye = nil
	local head = nil
	local ok_eye = pcall(function() enemy_eye = threat:get_eye_position() end)
	local ok_head = pcall(function()
		head = me:get_hitbox_position(0)
		if head then
			head.z = head.z + 6
		end
	end)

	if not (ok_eye and ok_head) or not enemy_eye or not head then
		return true
	end

	local ok, dmg = pcall(function()
		return utils.trace_bullet(threat, enemy_eye, head)
	end)

	if not ok or dmg == nil then
		return true
	end

	return dmg > 0
end

function bs_safe_head.think(arg_224_0)
	local var_224_0 = entity.get_local_player()

	if not var_224_0 or not var_224_0:is_alive() then
		return false
	end

	if not bs_menu.antiaim.general.safe_head.switch:get() then
		return false
	end

	-- Never during freestanding or manual yaw.
	if bs_freestanding.think(arg_224_0) or bs_manual_yaw.think() then
		return false
	end

	-- Never while fakelag is enabled and actively choking commands.
	local fakelag_on = false
	pcall(function()
		local fl = bs_config.antiaim.fake_lag
		fakelag_on = fl.enabled:get() or fl.enabled_pui:get()
	end)
	local choked = arg_224_0 and arg_224_0.choked_commands
	if fakelag_on and choked ~= nil and choked ~= 0 then
		return false
	end

	-- Target: prefer the engine threat, but use the closest alive, non-dormant
	-- enemy when it is nearer (get_threat can point at a far enemy).
	local my_origin = nil
	pcall(function() my_origin = var_224_0:get_origin() end)

	local var_224_1 = entity.get_threat(true) or entity.get_threat()
	local closest_dist = math.huge
	if var_224_1 and my_origin then
		pcall(function()
			local org = var_224_1:get_origin()
			if org then closest_dist = my_origin:dist(org) end
		end)
	end

	if my_origin then
		local closest, closest_d = nil, math.huge
		pcall(function()
			bs_iter_players(true, false, function(p)
				local ok_a, al = pcall(function() return p:is_alive() end)
				local ok_d, dm = pcall(function() return p:is_dormant() end)
				if ok_a and al and not (ok_d and dm) then
					local org = nil
					pcall(function() org = p:get_origin() end)
					if org then
						local d = my_origin:dist(org)
						if d < closest_d then
							closest_d = d
							closest = p
						end
					end
				end
			end)
		end)
		if closest and closest_d < closest_dist then
			var_224_1 = closest
			closest_dist = closest_d
		end
	end

	if not var_224_1 then
		return false
	end

	local var_224_3 = bs_detect_state(arg_224_0, var_224_0)

	-- Combat conditions only.
	if arg_224_0 and arg_224_0.in_attack then
		return false
	end

	local var_224_4 = var_224_0:get_player_weapon()
	if not var_224_4 then
		return false
	end

	-- Enemy must be alive and not dormant.
	local ok_alive, alive = pcall(function() return var_224_1:is_alive() end)
	local ok_dormant, dormant = pcall(function() return var_224_1:is_dormant() end)
	if not (ok_alive and alive) or (ok_dormant and dormant) then
		return false
	end

	-- Distance gate: only trigger when the closest threat is within 1500 units.
	local target_origin = nil
	pcall(function() target_origin = var_224_1:get_origin() end)
	if my_origin and target_origin and my_origin:dist(target_origin) > 1500 then
		return false
	end

	-- The defensive "safe head" state decides whether safe head fires.
	-- (The general Safe Head switch above is the master on/off.)
	local def_enabled = false
	pcall(function()
		local s = bs_v550.settings["safe head"]
		if s and s.enable then
			def_enabled = s.enable:get()
		end
	end)
	if not def_enabled then
		return false
	end

	-- Per-state gating: only these states may trigger. Hittability is handled
	-- above by the defensive "safe head" enable, so it is NOT required here.
	-- "sneaking" is crouch-while-moving, so it is allowed to make crouch reliable.
	if var_224_3 ~= "standing" and var_224_3 ~= "air" and var_224_3 ~= "air crouching" and var_224_3 ~= "crouching" and var_224_3 ~= "sneaking" then
		-- running, slowing: never.
		return false
	end

	-- Hysteria geometric trigger. Decides whether the current head exposure is
	-- dangerous enough to warrant a safe-head (defensive) angle.
	local smart = false
	pcall(function()
		local s = bs_menu.antiaim.general.safe_head.smart
		if s then smart = s:get() end
	end)

	if smart then
		-- SMART: ratio = (my_head.z - threat_eye.z) / threat_dist must fall inside
		-- a per-state danger band. Outside the band -> safe head.
		local threat_eye = nil
		local head = nil
		local ok_eye = pcall(function() threat_eye = var_224_1:get_eye_position() end)
		local ok_head = pcall(function() head = var_224_0:get_hitbox_position(0) end)

		if not (ok_eye and ok_head) or not threat_eye or not head then
			return false
		end

		local dist = nil
		pcall(function()
			local o = var_224_1:get_origin()
			if o and my_origin then dist = my_origin:dist(o) end
		end)
		if not dist or dist <= 0 then
			return false
		end

		local ratio = (head.z - threat_eye.z) / dist

		local min_r, max_r = 0, 0.75
		if var_224_0.m_fFlags and bit.band(var_224_0.m_fFlags, 1) == 1 and not (var_224_0.m_flDuckAmount and var_224_0.m_flDuckAmount > 0.5) then
			-- on ground, standing
			min_r, max_r = 0.25, 0.5
		elseif var_224_0.m_fFlags and bit.band(var_224_0.m_fFlags, 1) == 1 and var_224_0.m_flDuckAmount and var_224_0.m_flDuckAmount > 0.5 then
			-- on ground, crouching
			min_r, max_r = -0.05, 0.3
		elseif var_224_3 == "air" then
			min_r, max_r = 0.15, 0.75
		elseif var_224_3 == "air crouching" then
			local is_knife = false
			pcall(function()
				local w = var_224_0:get_player_weapon()
				local info = w and w:get_weapon_info()
				is_knife = (w and w:get_classname() == "CKnife") or (info and info.weapon_type == 7)
			end)
			if is_knife then
				min_r, max_r = -0.05, 0.55
			else
				min_r, max_r = 0.1, 0.75
			end
		end

		-- ratio within band => head is "safe" already, do nothing.
		-- ratio outside band => trigger safe head.
		if ratio >= min_r and ratio <= max_r then
			return false
		end

		return true, nil, var_224_3
	else
		-- BASIC: jump + (my_origin.z - threat_origin.z) > -32 with a non-knife.
		local jumping = not (var_224_0.m_fFlags and bit.band(var_224_0.m_fFlags, 1) == 1)
		if not jumping then
			return false
		end

		local target_origin = nil
		pcall(function() target_origin = var_224_1:get_origin() end)
		if not (my_origin and target_origin) then
			return false
		end

		if my_origin.z - target_origin.z <= -32 then
			return false
		end

		return true, nil, var_224_3
	end
end

function bs_safe_head.update(arg_227_0, arg_227_1, arg_227_2)
	bs_safe_head.active = false

	local var_227_0, var_227_1, var_227_2 = bs_safe_head.think(arg_227_0)

	if not var_227_0 then
		pcall(function()
			bs_config.antiaim.angles.options:override()
		end)
		return false
	end

	if bs_freestanding.think() or bs_manual_yaw.think() then
		return false
	end

	local var_227_5 = entity.get_local_player()
	local var_227_6 = var_227_5 and var_227_5.m_vecVelocity and var_227_5.m_vecVelocity:length2d() or 0
	local var_227_7 = 0
	local var_227_8 = 0

	-- Per-state safe-head profile
	local var_227_3 = var_227_2  -- state (standing/running/air/air crouching)

	local var_227_p = bs_safe_head.profiles[var_227_3]

	if not var_227_p then
		return false
	end

	var_227_7 = var_227_p.yaw_offset
	var_227_8 = var_227_p.limit

	local var_227_10 = math.max(0, math.min(58, var_227_8))

	arg_227_1.pitch = var_227_p.pitch
	arg_227_1.yaw = "backward"
	arg_227_1.yaw_base = "At target"
	arg_227_1.avoid_backstab = false
	arg_227_1.yaw_offset = var_227_7
	arg_227_1.yaw_modifier = "Disabled"
	arg_227_1.modifier_offset = 0
	arg_227_1.body_yaw = true
	arg_227_1.inverter = false
	arg_227_1.left_limit = var_227_10
	arg_227_1.right_limit = var_227_10
	arg_227_1.body_yaw_options = {}
	arg_227_1.freestanding = false
	arg_227_1.body_freestanding = false
	arg_227_1.freestand_peek = "off"
	arg_227_1.disable_yaw_modifiers = true

	bs_config.antiaim.angles.options:override({})

	bs_safe_head.active = true

	pcall(function()
		local var_227_11 = bs_menu.info and bs_menu.info.notify
		if var_227_11 and var_227_11.log_enabled:get() then
			local var_227_12 = entity.get(arg_227_0.threat_index or 1)
			local var_227_13 = var_227_12 and var_227_12:get_name() or "unknown"
			local var_227_14 = globals.realtime

			if var_227_13 ~= bs_safe_head.last_log_target or var_227_14 - bs_safe_head.last_log_time > 1 then
				bs_safe_head.last_log_target = var_227_13
				bs_safe_head.last_log_time = var_227_14
			end
		end
	end)

	return true
end

bs_ai_peek = {}
function bs_v31(arg_243_0)
	if (arg_243_0.m_flDuckAmount or 0) < 0.6 then
		return false
	end

	local var_243_0, var_243_1 = pcall(function()
		return arg_243_0:get_eye_position()
	end)
	local var_243_2, var_243_3 = pcall(function()
		return arg_243_0:get_origin()
	end)

	if not var_243_0 or not var_243_2 or not var_243_1 or not var_243_3 then
		return false
	end

	return var_243_1.z - var_243_3.z > 56
end

function bs_v45(arg_246_0, arg_246_1, arg_246_2, arg_246_3, arg_246_4)
	local var_246_0 = math.clamp(bs_v636:get(), 1, 130)
	local var_246_1 = {}

	for iter_246_0 = 0, 10 do
		if arg_246_0[iter_246_0] then
			var_246_1[#var_246_1 + 1] = arg_246_0[iter_246_0]
		end
	end

	for iter_246_1 = 1, 10 do
		if arg_246_1[iter_246_1] then
			var_246_1[#var_246_1 + 1] = arg_246_1[iter_246_1]
		end
	end

	for iter_246_2 = 1, #var_246_1 do
		local var_246_2 = var_246_1[iter_246_2]

		for iter_246_3 = 1, #arg_246_4 do
			local var_246_3 = arg_246_4[iter_246_3]
			local var_246_4 = arg_246_3:get_hitbox_position(var_246_3)

			if var_246_4 then
				if var_246_3 == 0 then
					var_246_4.z = var_246_4.z + 5.2
				end

				local var_246_5 = utils.trace_bullet(arg_246_2, var_246_2, var_246_4, bs_v702)

				if var_246_5 and var_246_0 <= var_246_5 then
					bs_v592.last_peek_pos = var_246_4

					return var_246_2, iter_246_2
				end
			end
		end
	end

	return nil, 0
end

function bs_v60()
	bs_v649:override()
	bs_v657:override()
	pcall(function()
		bs_v665:override()
	end)
	pcall(function()
		bs_v674:override()
	end)
end

bs_v75 = false
bs_v90 = false
bs_v105 = false
bs_v121 = false
bs_v138 = false
bs_v156 = false
bs_v181 = false
bs_v204 = 0
bs_v222 = false
bs_v242 = nil
bs_v261 = nil
bs_v276 = 0
bs_v290 = false
bs_v304 = 0
bs_v317 = false
bs_v329 = -100

events.level_init(function()
	bs_v222 = false
	bs_v242 = nil
	bs_v261 = nil
	bs_v276 = 0
	bs_v290 = false
	bs_v304 = 0
	bs_v317 = false
	bs_v329 = -100
end)

bs_v342 = {
	"CKnife",
	"CKnifeGold",
	"CKnifeCT",
	"CKnifeT",
	"CKnifeGhost",
	"CKnifeWidowmaker",
	"CKnifeCaesar",
	"CKnifeSkeletonKnife",
	"CKnifeCord",
	"CKnifeFalchion",
	"CKnifeButterfly",
	"CKnifeKarambit",
	"CKnifeM9Bayonet",
	"CKnifeTactical",
	"CKnifeFlip",
	"CKnifeGut",
	"CKnifeHunter",
	"CKnifeNomad",
	"CKnifeParacord",
	"CKnifeShadowDagger",
	"CKnifeStiletto",
	"CKnifeSurvivalBowie",
	"CKnifeUrsus",
	"CKnifeYatagan"
}

function bs_v356(arg_251_0)
	local var_251_0 = arg_251_0:get_index()

	for iter_251_0, iter_251_1 in ipairs(bs_v342) do
		local var_251_1, var_251_2 = pcall(entity.get_entities, iter_251_1)

		if var_251_1 and var_251_2 then
			for iter_251_2, iter_251_3 in ipairs(var_251_2) do
				local var_251_3 = iter_251_3.m_hOwnerEntity

				if var_251_3 and var_251_3:get_index() == var_251_0 then
					return iter_251_3
				end
			end
		end
	end

	for iter_251_4, iter_251_5 in ipairs(entity.get_entities("CBaseCombatWeapon")) do
		local var_251_4 = iter_251_5.m_hOwnerEntity

		if var_251_4 and var_251_4:get_index() == var_251_0 then
			local var_251_5 = iter_251_5:get_classname()

			if var_251_5:find("knife") or var_251_5:find("bayonet") or var_251_5 == "weapon_knifegg" then
				return iter_251_5
			end
		end
	end

	return nil
end

function bs_v367(arg_252_0)
	bs_v912 = bs_menu.antiaim.general.aipeek.switch.value or bs_hotkeys:is_active("ai peek")

	if bs_v912 then
		bs_v329 = globals.tickcount
	end

	if bs_v912 and not bs_v181 then
		bs_v181 = true
		bs_v75 = false
		bs_v90 = false
		bs_v592.middle_pos = entity.get_local_player() and entity.get_local_player():get_origin() or vector()
	elseif not bs_v912 and bs_v181 then
		bs_v181 = false
		bs_v75 = false
		bs_v90 = false
		bs_v204 = 0
		cached_index = 0
		bs_v592.active_point_index = 0

		bs_v60()
	end

	if not bs_v912 then
		return
	end

	bs_v913, bs_v914 = pcall(function()
		return bs_v599:get()
	end)

	if bs_v913 and bs_v914 then
		bs_v916 = table.concat(bs_v914)

		if bs_v916 ~= bs_v592.rage_hitboxes_str then
			bs_v691(bs_v599)

			bs_v592.rage_hitboxes_str = bs_v916
		end
	end

	if #bs_v553 == 0 then
		bs_v691(bs_v599)
	end

	bs_v915 = entity.get_local_player()

	if not bs_v915 or not bs_v915:is_alive() then
		bs_v75 = false
		bs_v90 = false
		bs_v156 = false
		bs_v105 = false
		bs_v138 = false

		bs_v60()

		return
	end

	bs_v917 = globals.tickcount
	bs_v918 = bit.band(bs_v915.m_fFlags or 0, 1) ~= 1 or arg_252_0.in_forward or arg_252_0.in_moveleft or arg_252_0.in_moveright or arg_252_0.in_back or arg_252_0.in_jump
	bs_v919 = bs_v915:get_origin()
	bs_v920 = bs_v592.middle_pos
	bs_v902 = bs_v920:dist2d(bs_v919)
	bs_v903 = entity.get_threat()

	if not bs_v903 or bs_v903:is_dormant() or not bs_v903:is_alive() then
		bs_v905 = bs_v915:get_origin()
		bs_v907 = math.huge
		bs_v909 = nil

		bs_iter_players(true, false, function(arg_254_0)
			if arg_254_0:is_dormant() or not arg_254_0:is_alive() then
				return
			end

			if bs_v31(arg_254_0) then
				return
			end

			local var_254_0 = bs_v905:dist(arg_254_0:get_origin())

			if var_254_0 < bs_v907 then
				bs_v907 = var_254_0
				bs_v909 = arg_254_0
			end
		end)

		bs_v903 = bs_v909
	end

	bs_v904 = bs_v903 and bs_v903:get_origin() or vector()
	bs_v906 = bs_v903 and bs_v920:to(bs_v904):angles().y or render.camera_angles().y
	bs_v908 = bs_v748(bs_v915, bs_v920, bs_v906)
	bs_v910 = nil
	bs_v911 = 0

	if not bs_v918 and not bs_v90 and bs_v18(bs_v915, bs_v903) and bs_v903 and not bs_v31(bs_v903) then
		bs_v910, bs_v911 = bs_v45(bs_v908, bs_v592.forward_positions, bs_v915, bs_v903, bs_v553)
	end

	bs_v75 = bs_v910 ~= nil
	bs_v592.active_point_index = bs_v911

	if bs_v75 then
		bs_v723(arg_252_0, bs_v910, bs_v915)

		bs_v90 = false
		bs_v156 = true
		bs_v105 = false
		bs_v121 = false
		bs_v138 = false
	elseif bs_v918 then
		bs_v90 = false
		bs_v156 = false
		bs_v105 = false
		bs_v121 = false
		bs_v138 = false
	else
		if bs_v204 > 0 then
			bs_v204 = bs_v204 - 1

			if bs_v902 >= 3 then
				bs_v723(arg_252_0, bs_v920, bs_v915)
			end
		elseif bs_v902 >= 3 then
			if not bs_v90 then
				bs_v105 = true
				bs_v121 = false
			end

			bs_v90 = true
		else
			bs_v90 = false
			bs_v105 = false
			bs_v121 = false
		end

		bs_v156 = false
	end

	if not bs_v90 then
		bs_v592.last_returning_time = bs_v917
	end

	if bs_v90 then
		if bs_v902 < 3 then
			bs_v90 = false
			bs_v105 = false
			bs_v121 = false
			bs_v138 = false
		elseif bs_v105 then
			if not bs_v121 then
				bs_v121 = true

				bs_config.antiaim.fake_lag.limit:override(14)
				bs_config.rage.main.double_tap_lag_options:override("Always on")
				pcall(function()
					rage.exploit:allow_defensive(true)
				end)
			elseif bs_v917 - bs_v592.last_returning_time >= 6 then
				pcall(function()
					rage.exploit:force_teleport()
				end)
				bs_config.antiaim.fake_lag.limit:override()

				bs_v105 = false
				bs_v121 = false
				bs_v90 = false
				bs_v138 = true
				bs_v204 = 20
			end
		end

		if not bs_v918 and bs_v902 >= 3 then
			bs_v723(arg_252_0, bs_v920, bs_v915)
		end
	end

	if bs_v75 or bs_v90 then
		bs_v649:override(true)
	else
		bs_v649:override()
	end

	if bs_v75 then
		bs_v657:override("On Shot")
	elseif bs_v90 then
		bs_v657:override({
			"On Shot",
			"On Key Release"
		})
	else
		bs_v657:override()
	end

	if bs_v105 or bs_v90 then
		bs_config.rage.main.double_tap_lag_options:override("Always on")
	else
		bs_config.rage.main.double_tap_lag_options:override()
	end

	if bs_v138 then
		pcall(function()
			bs_v665:override()
		end)
		pcall(function()
			bs_v674:override()
		end)
	end
end

bs_v377 = 0
bs_v392 = {}
bs_v401 = 64
bs_v409 = 0.9
bs_v417 = 0
bs_v424 = 0.016
bs_v429 = 0
bs_v433 = 0
bs_v437 = 0
bs_v441 = 7
bs_v445 = 0
bs_v449 = 0
bs_v453 = 0
bs_v456 = 0
bs_v458 = 0
bs_v460 = 0
bs_v462 = false
bs_v465 = false

function bs_v467(arg_259_0)
	return math.max(0, math.min(255, math.floor(arg_259_0 + 0.5)))
end

function bs_v469(arg_260_0, arg_260_1, arg_260_2, arg_260_3, arg_260_4, arg_260_5, arg_260_6, arg_260_7)
	if arg_260_7 < 3 then
		return
	end

	local var_260_0 = arg_260_2 - arg_260_0
	local var_260_1 = arg_260_3 - arg_260_1
	local var_260_2 = math.sqrt(var_260_0 * var_260_0 + var_260_1 * var_260_1)

	if var_260_2 < 0.5 then
		return
	end

	local var_260_3 = 1 / var_260_2
	local var_260_4 = -var_260_1 * var_260_3
	local var_260_5 = var_260_0 * var_260_3
	local var_260_6 = {
		{
			d = 5,
			ao = 0.3
		},
		{
			d = 3,
			ao = 0.52
		},
		{
			d = 2,
			ao = 0.72
		},
		{
			d = 1,
			ao = 0.9
		},
		{
			bright = true,
			d = 0,
			ao = 1
		}
	}

	for iter_260_0, iter_260_1 in ipairs(var_260_6) do
		local var_260_7 = bs_v467(arg_260_7 * iter_260_1.ao)

		if var_260_7 < 2 then
			-- block empty
		else
			local var_260_8 = iter_260_1.bright and bs_v467(arg_260_4 + 80) or arg_260_4
			local var_260_9 = iter_260_1.bright and bs_v467(arg_260_5 + 80) or arg_260_5
			local var_260_10 = iter_260_1.bright and bs_v467(arg_260_6 + 80) or arg_260_6
			local var_260_11 = color(var_260_8, var_260_9, var_260_10, var_260_7)

			if iter_260_1.d > 0 then
				render.line(vector(math.floor(arg_260_0 + var_260_4 * iter_260_1.d + 0.5), math.floor(arg_260_1 + var_260_5 * iter_260_1.d + 0.5)), vector(math.floor(arg_260_2 + var_260_4 * iter_260_1.d + 0.5), math.floor(arg_260_3 + var_260_5 * iter_260_1.d + 0.5)), var_260_11)
				render.line(vector(math.floor(arg_260_0 - var_260_4 * iter_260_1.d + 0.5), math.floor(arg_260_1 - var_260_5 * iter_260_1.d + 0.5)), vector(math.floor(arg_260_2 - var_260_4 * iter_260_1.d + 0.5), math.floor(arg_260_3 - var_260_5 * iter_260_1.d + 0.5)), var_260_11)
			else
				render.line(vector(math.floor(arg_260_0 + 0.5), math.floor(arg_260_1 + 0.5)), vector(math.floor(arg_260_2 + 0.5), math.floor(arg_260_3 + 0.5)), var_260_11)
			end
		end
	end
end

function bs_v471(arg_261_0, arg_261_1, arg_261_2, arg_261_3, arg_261_4, arg_261_5, arg_261_6)
	if arg_261_5 < 4 then
		return
	end

	local var_261_0 = arg_261_6 or 0
	local var_261_1 = math.floor(arg_261_0 + 0.5)
	local var_261_2 = math.floor(arg_261_1 + 0.5)

	render.circle_outline(vector(var_261_1, var_261_2), color(arg_261_2, arg_261_3, arg_261_4, bs_v467(arg_261_5 * 0.42)), bs_v467(8 + var_261_0 * 2), 0, 360, 3)
	render.circle_outline(vector(var_261_1, var_261_2), color(arg_261_2, arg_261_3, arg_261_4, bs_v467(arg_261_5 * 0.68)), bs_v467(6 + var_261_0), 0, 360, 2)
	render.circle_outline(vector(var_261_1, var_261_2), color(bs_v467(arg_261_2 + 50), bs_v467(arg_261_3 + 50), bs_v467(arg_261_4 + 50), bs_v467(arg_261_5 * 0.9)), 4, 0, 360, 1)
	render.circle_outline(vector(var_261_1, var_261_2), color(bs_v467(arg_261_2 + 80), bs_v467(arg_261_3 + 80), bs_v467(arg_261_4 + 80), arg_261_5), 2, 0, 360, 1)
	render.circle(vector(var_261_1, var_261_2), color(bs_v467(arg_261_2 + 100), bs_v467(arg_261_3 + 100), bs_v467(arg_261_4 + 100), arg_261_5), 1, 0, 360)
end

bs_v473 = nil
bs_v475 = nil
bs_v476 = false
bs_v477 = {}

function bs_v478(arg_262_0, arg_262_1, arg_262_2, arg_262_3)
	if not (arg_262_0.switch.value or bs_hotkeys:is_active("ai peek")) then
		bs_v392 = {}
		bs_v417 = 0
		bs_v462 = false
		bs_v433 = 0
		bs_v437 = 0
		bs_v473 = nil
		bs_v475 = nil
		bs_v476 = false

		return
	end

	bs_v968 = arg_262_1:get_origin()
	bs_v969 = arg_262_1.m_vecViewOffset
	bs_v970 = bs_v75 or bs_v90
	bs_v971 = render.world_to_screen(vector(bs_v968.x, bs_v968.y, bs_v968.z + bs_v969.z * 0.82))

	if not bs_v971 then
		return
	end

	bs_v972 = bs_v971.y
	bs_v921 = bs_v971.x
	bs_v922 = false

	if bs_v473 then
		bs_v924 = bs_v968.x - bs_v473
		bs_v926 = bs_v968.y - bs_v475

		if bs_v924 * bs_v924 + bs_v926 * bs_v926 > 10000 then
			bs_v922 = true
		end
	end

	bs_v473 = bs_v968.x
	bs_v475 = bs_v968.y
	bs_v923 = arg_262_0.color.value
	bs_v925 = bs_v923.r
	bs_v927 = bs_v923.g
	bs_v928 = bs_v923.b
	bs_v929 = bs_v923.a

	if bs_v922 then
		bs_v392 = {}
		bs_v462 = false
		bs_v437 = 0
		bs_v433 = 0
		bs_v476 = false
		bs_v592.last_peek_pos = nil
	end

	if not bs_v970 or not bs_v592.last_peek_pos then
		bs_v437 = 0
		bs_v433 = 0
		bs_v392 = {}
		bs_v476 = false

		if bs_v453 == 0 then
			bs_v453 = bs_v921
		end

		bs_v932 = 1 - math.exp(-16 * math.min(arg_262_3, 0.05))
		bs_v453 = bs_v453 + (bs_v921 - bs_v453) * bs_v932
		bs_v934 = math.abs(bs_v453 - bs_v921)

		if bs_v934 < 1.5 then
			bs_v453 = bs_v921
			bs_v462 = false
		end

		bs_v936 = (math.sin(arg_262_2 * 3.4) * 0.5 + 0.5)^2
		bs_v938 = bs_v934 < 6 and bs_v467(bs_v929 * (0.65 + 0.35 * bs_v936)) or bs_v467(bs_v929 * math.min(0.8, bs_v934 / 80))
		bs_v940 = bs_v934 < 6 and bs_v936 or 0

		bs_v471(math.floor(bs_v453 + 0.5), math.floor(bs_v972 + 0.5), bs_v925, bs_v927, bs_v928, bs_v938, bs_v940)

		return
	end

	bs_v476 = false
	bs_v931 = nil
	bs_v933 = render.screen_size().x
	bs_v935 = bs_v933 * 0.5
	bs_v937 = 200
	bs_v939 = arg_262_1.m_vecVelocity
	bs_v941 = bs_v939.x
	bs_v942 = bs_v939.y
	bs_v943 = math.sqrt(bs_v941 * bs_v941 + bs_v942 * bs_v942)

	if bs_v943 > 20 then
		bs_v946 = render.camera_angles().y * math.pi / 180
		bs_v949 = bs_v941 * math.sin(bs_v946) - bs_v942 * math.cos(bs_v946)
		bs_v931 = bs_v921 + math.max(-1, math.min(1, bs_v949 / math.max(bs_v943, 1))) * bs_v937
	else
		bs_v945 = bs_v592.last_peek_pos

		if bs_v945 then
			bs_v948 = render.world_to_screen(vector(bs_v945.x, bs_v945.y, bs_v945.z + bs_v969.z * 0.82))

			if bs_v948 then
				bs_v931 = math.max(bs_v921 - bs_v937, math.min(bs_v921 + bs_v937, bs_v948.x))
			else
				bs_v931 = bs_v462 and bs_v453 or bs_v921
			end
		else
			bs_v931 = bs_v462 and bs_v453 or bs_v921
		end
	end

	bs_v930 = math.max(bs_v921 - bs_v937, math.min(bs_v921 + bs_v937, bs_v931))

	if not bs_v462 then
		bs_v453 = bs_v921
		bs_v445 = bs_v921
		bs_v458 = 0
		bs_v462 = true
	end

	bs_v944 = 1 - math.exp(-4 * math.min(arg_262_3, 0.05))
	bs_v947 = bs_v930 - bs_v453
	bs_v950 = bs_v933 * 0.05
	bs_v458 = math.max(-bs_v950, math.min(bs_v950, bs_v947))
	bs_v453 = bs_v453 + bs_v458 * bs_v944
	bs_v453 = math.max(bs_v921 - bs_v937, math.min(bs_v921 + bs_v937, bs_v453))
	bs_v445 = bs_v453
	bs_v951 = math.floor(bs_v453 + 0.5)
	bs_v952 = math.floor(bs_v972 + 0.5)

	if arg_262_2 >= bs_v417 then
		bs_v417 = arg_262_2 + bs_v424
		bs_v954 = bs_v392[#bs_v392]
		bs_v956 = bs_v954 and bs_v453 - bs_v954.x or 999

		if bs_v956 * bs_v956 >= 1.5 then
			bs_v392[#bs_v392 + 1] = {
				x = bs_v453,
				y = bs_v972,
				born = arg_262_2
			}

			if #bs_v392 > bs_v401 then
				table.remove(bs_v392, 1)
			end
		end
	end

	bs_v953 = {}

	for iter_262_0, iter_262_1 in ipairs(bs_v392) do
		if arg_262_2 - iter_262_1.born < bs_v409 then
			iter_262_1.y = bs_v972
			bs_v953[#bs_v953 + 1] = iter_262_1
		end
	end

	bs_v392 = bs_v953
	bs_v437 = 1
	bs_v433 = 1
	bs_v955 = #bs_v392

	if bs_v955 >= 1 then
		for iter_262_2 = 1, bs_v955 do
			bs_v477[iter_262_2] = bs_v392[iter_262_2]
		end

		bs_v477[bs_v955 + 1] = {
			x = bs_v453,
			y = bs_v972,
			born = arg_262_2
		}

		for iter_262_3 = bs_v955 + 2, #bs_v477 do
			bs_v477[iter_262_3] = nil
		end

		bs_v958 = bs_v955 + 1
		bs_v960 = bs_v477[1].born
		bs_v961 = bs_v477[bs_v958].born
		bs_v962 = math.max(0.001, bs_v961 - bs_v960)

		for iter_262_4 = 2, bs_v958 do
			bs_v963 = bs_v477[iter_262_4 - 1]
			bs_v964 = bs_v477[iter_262_4]
			bs_v965 = ((bs_v963.born + bs_v964.born) * 0.5 - bs_v960) / bs_v962
			bs_v966 = bs_v965 * bs_v965 * (3 - 2 * bs_v965)
			bs_v967 = bs_v467(bs_v929 * bs_v966)

			if bs_v967 >= 4 then
				bs_v469(bs_v963.x, bs_v972, bs_v964.x, bs_v972, bs_v925, bs_v927, bs_v928, bs_v967)
			end
		end
	end

	bs_v957 = (math.sin(arg_262_2 * 3.4) * 0.5 + 0.5)^2
	bs_v959 = bs_v467(bs_v929 * (0.85 + 0.15 * bs_v957))

	bs_v471(bs_v951, bs_v952, bs_v925, bs_v927, bs_v928, bs_v959, bs_v957)
end

-- #############################################################################
-- #  [SEC-10] AIMBOT / PEEK ASSIST
-- #############################################################################
function bs_ai_peek_render()
	local var_263_0 = bs_menu.antiaim.general.aipeek

	if not (var_263_0.switch.value or bs_hotkeys:is_active("ai peek")) then
		bs_v392 = {}
		bs_v417 = 0
		bs_v433 = 0

		return
	end

	local var_263_1 = entity.get_local_player()

	if not var_263_1 or not var_263_1:is_alive() then
		bs_v392 = {}
		bs_v417 = 0
		bs_v433 = 0

		return
	end

	local var_263_2 = globals.realtime
	local var_263_3 = math.min(var_263_2 - bs_v377, 0.05)

	bs_v377 = var_263_2

	bs_v478(var_263_0, var_263_1, var_263_2, var_263_3)
end

function bs_ai_peek.on_createmove(arg_264_0, arg_264_1)
	local var_264_0, var_264_1 = pcall(bs_v367, arg_264_1)

	if not var_264_0 then
		bs_v75 = false
		bs_v90 = false
		bs_v156 = false
		bs_v105 = false
		bs_v138 = false

		bs_v60()
	end
end

function bs_ai_peek.on_render(arg_265_0)
	pcall(bs_ai_peek_render)
end

events.aim_fire(function(arg_266_0)
	local var_266_0 = bs_menu.antiaim.general.aipeek

	if not var_266_0.switch_to_knife.value then
		return
	end

	local var_266_1 = globals.tickcount
	local var_266_2, var_266_3 = pcall(function()
		return bs_v649:get()
	end)
	local var_266_4 = var_266_0.switch.value or bs_hotkeys:is_active("ai peek")
	local var_266_5 = var_266_1 - bs_v329 <= 6

	if not var_266_4 and (not var_266_2 or not var_266_3) and not var_266_5 then
		return
	end

	local var_266_6 = entity.get_local_player()

	if not var_266_6 or not var_266_6:is_alive() then
		return
	end

	local var_266_7 = var_266_6:get_player_weapon()

	if not var_266_7 then
		return
	end

	local var_266_8 = var_266_7:get_classname()

	if var_266_8 ~= "CWeaponAWP" and var_266_8 ~= "CWeaponSSG08" then
		return
	end

	if var_266_8:find("knife") or var_266_8:find("bayonet") or var_266_8 == "weapon_knifegg" then
		return
	end

	if not bs_v222 then
		bs_v242 = var_266_7:get_index()
		bs_v261 = var_266_8
	end

	bs_v317 = true
	bs_v222 = false
	bs_v290 = false
	bs_v304 = 0
end)
events.createmove(function(arg_268_0)
	local var_268_0 = bs_menu.antiaim.general.aipeek

	if not var_268_0.switch_to_knife.value then
		bs_v222 = false
		bs_v290 = false
		bs_v304 = 0
		bs_v317 = false
		bs_v242 = nil
		bs_v261 = nil

		return
	end

	local var_268_1, var_268_2 = pcall(function()
		return bs_v649:get()
	end)

	if var_268_0.switch.value or bs_hotkeys:is_active("ai peek") or var_268_1 and var_268_2 then
		bs_v329 = globals.tickcount
	end

	local var_268_3 = entity.get_local_player()

	if not var_268_3 or not var_268_3:is_alive() then
		bs_v222 = false
		bs_v290 = false
		bs_v304 = 0
		bs_v317 = false
		bs_v242 = nil
		bs_v261 = nil

		return
	end

	local var_268_4 = var_268_3:get_player_weapon()
	local var_268_5 = var_268_4 and var_268_4:get_classname() or ""
	local var_268_6 = var_268_5:find("knife") or var_268_5:find("bayonet") or var_268_5 == "weapon_knifegg"

	if bs_v290 and not var_268_6 then
		if not bs_v4[var_268_5] then
			bs_v290 = false
			bs_v304 = 0
		elseif globals.tickcount - bs_v304 >= 3 then
			local var_268_7, var_268_8 = pcall(function()
				return var_268_3.m_bIsScoped
			end)

			if var_268_7 and var_268_8 then
				bs_v290 = false
			else
				arg_268_0.in_attack2 = true
			end
		end
	end

	if bs_v317 then
		local var_268_9 = bs_v356(var_268_3)

		if var_268_9 then
			arg_268_0.weaponselect = var_268_9:get_index()
			bs_v276 = globals.tickcount
			bs_v222 = true
			bs_v317 = false
		else
			bs_v317 = false
		end
	elseif bs_v222 and globals.tickcount - bs_v276 >= 1 then
		if bs_v242 then
			arg_268_0.weaponselect = bs_v242

			if bs_v4[bs_v261] then
				bs_v290 = true
				bs_v304 = globals.tickcount
			end

			bs_v242 = nil
			bs_v261 = nil
		end

		bs_v222 = false
	end
end)
events.createmove(function(arg_271_0)
	bs_hotkeys:update()
	bs_ai_peek:on_createmove(arg_271_0)
end)
events.render(function()
	local var_272_0 = entity.get_local_player()

	if not var_272_0 or not var_272_0:is_alive() then
		return
	end

	bs_ai_peek:on_render()
end)

bs_legit_aa = {}
bs_legit_aa.is_working = false

function bs_v544(arg_273_0)
	local var_273_0 = arg_273_0:get_eye_position()
	local var_273_1 = render.camera_angles()
	local var_273_2 = var_273_0 + vector():angles(var_273_1) * 128
	local var_273_3 = utils.trace_line(var_273_0, var_273_2, 4294967295)

	if var_273_3.entity == nil then
		return false
	end

	local var_273_4 = var_273_3.entity:get_classname()

	return var_273_4:find("Weapon") or var_273_4:find("Door")
end

function bs_v552(arg_274_0)
	if arg_274_0.m_iTeamNum ~= 3 then
		return false
	end

	local var_274_0 = arg_274_0:get_origin()

	for iter_274_0, iter_274_1 in ipairs(entity.get_entities("CPlantedC4")) do
		if iter_274_1 then
			local var_274_1 = iter_274_1:get_origin()

			if var_274_1 and iter_274_1.m_bBombTicking and var_274_0:dist(var_274_1) < 87.5 then
				return true
			end
		end
	end
end

function bs_v561(arg_275_0)
	local var_275_0 = arg_275_0:get_eye_position()
	local var_275_1 = render.camera_angles()
	local var_275_2 = var_275_0 + vector():angles(var_275_1) * 128
	local var_275_3 = utils.trace_hull(var_275_0, var_275_2, vector(-1, -1, -1), vector(1, 1, 1), arg_275_0, bit.bor(1, 2, 8, 16384, 33554432))

	if var_275_3.entity == nil then
		return false
	end

	return arg_275_0:get_origin():dist(var_275_3.entity:get_origin()) < 125 and var_275_3.entity:get_classid() == 97
end

function bs_v573(arg_276_0, arg_276_1, arg_276_2)
	if arg_276_2 and arg_276_2:get_classname() == "CC4" then
		return true
	end

	return bs_v544(arg_276_1) or bs_v552(arg_276_1) or bs_v561(arg_276_1)
end

function bs_legit_aa.think(arg_277_0)
	local var_277_0 = entity.get_local_player()

	if var_277_0 == nil or not var_277_0:is_alive() then
		return false
	end

	local var_277_1 = var_277_0:get_player_weapon()

	if var_277_1 == nil then
		return false
	end

	if not bs_menu.antiaim.general.legit_aa.enabled:get() then
		return false
	end

	if not arg_277_0.in_use then
		return false
	end

	return not bs_v573(arg_277_0, var_277_0, var_277_1)
end

function bs_legit_aa.update(arg_278_0, arg_278_1, arg_278_2)
	bs_legit_aa.is_working = bs_legit_aa.think(arg_278_0)

	if not bs_legit_aa.is_working then
		return
	end

	arg_278_0.in_use = false
	arg_278_1.pitch = "Disabled"
	arg_278_1.yaw_base = bs_menu.antiaim.general.legit_aa.mode:get()
end

bs_defensive_mgr = nil
bs_break_lc = {}
bs_v559 = {
	restore = false,
	forced = false
}

function bs_v572()
	pcall(function()
		bs_config.rage.main.double_tap_lag_options_pui:override("Always On")
	end)
	pcall(function()
		bs_config.rage.main.double_tap_lag_options_pui:override("Always on")
	end)
	pcall(function()
		bs_config.rage.main.double_tap_lag_options:override("Always On")
	end)
	pcall(function()
		rage.exploit:allow_defensive(true)
	end)
end

function bs_v579()
	pcall(function()
		bs_config.rage.main.double_tap_lag_options_pui:set("On Peek")
	end)
	pcall(function()
		bs_config.rage.main.double_tap_lag_options:override("On Peek")
	end)
end

function bs_v559.reset(arg_287_0)
	arg_287_0.forced = false

	bs_config.antiaim.fake_lag.enabled_pui:override()
	bs_config.antiaim.fake_lag.limit_pui:override()
end

function bs_v559.force(arg_288_0)
	bs_v572()

	arg_288_0.forced = true
end

function bs_v559.on_net_update_end(arg_289_0)
	local var_289_0, var_289_1 = pcall(function()
		return rage.exploit:get() == 1
	end)

	if not var_289_0 or not var_289_1 then
		arg_289_0:reset()

		return
	end

	if arg_289_0.forced then
		arg_289_0.forced = false

		bs_v572()

		arg_289_0.restore = true

		return
	end

	if arg_289_0.restore then
		arg_289_0.restore = false

		bs_v579()
	end

	if not bs_break_lc.should_force() then
		bs_config.antiaim.fake_lag.enabled_pui:override()
		bs_config.antiaim.fake_lag.limit_pui:override()
	end
end

-- #############################################################################
-- #  [SEC-11] BREAK LAG COMPENSATION / LEGIT AA
-- #############################################################################
function bs_break_lc.think(arg_291_0)
	local var_291_0 = entity.get_local_player()

	if var_291_0 == nil or not var_291_0:is_alive() then
		return false
	end

	local var_291_1 = var_291_0:get_player_weapon()

	if var_291_1 == nil then
		return false
	end

	local var_291_2 = bs_menu.antiaim.general.break_lc

	if not var_291_2.select:get() then
		return false
	end

	local var_291_3 = var_291_1.m_fThrowTime

	if var_291_3 ~= nil and var_291_3 ~= 0 then
		return false
	end

	if var_291_2.additions_normal and var_291_2.additions_normal:get("ignore grenade") and var_291_1:get_weapon_info().weapon_type == 9 then
		return false
	end

	return true
end

function bs_break_lc_evt(arg_292_0)
	local var_292_0 = entity.get_local_player()

	if not var_292_0 or not var_292_0:is_alive() or not arg_292_0 or not arg_292_0.events then
		return false
	end

	if arg_292_0.events:get("weapon switch") and var_292_0.m_flNextAttack and var_292_0.m_flNextAttack > globals.curtime then
		return true
	end

	local var_292_1 = var_292_0:get_player_weapon()

	if var_292_1 and arg_292_0.events:get("weapon reload") then
		local var_292_2, var_292_3 = pcall(function()
			return var_292_1:get_weapon_reload()
		end)

		if var_292_2 and var_292_3 ~= -1 then
			return true
		end
	end

	if arg_292_0.events:get("on peek") and arg_292_0.conditions:get("quickpeek") then
		local var_292_4, var_292_5 = pcall(function()
			return bs_config.rage.main.double_tap:get()
		end)

		if var_292_4 and var_292_5 and rage.exploit:get() == 1 then
			local var_292_6 = bs_get_state.get()
			if var_292_6 == "running" then
				return true
			end
		end
	end

	return false
end

function bs_break_lc.should_force(arg_294_0)
	if not bs_break_lc.think(arg_294_0) then
		return false
	end

	local var_294_0 = bs_menu.antiaim.general.break_lc

	if bs_break_lc_evt(var_294_0) then
		return true
	end

	local var_294_1 = bs_get_state.get()
	local var_294_2 = var_294_0.activate and var_294_0.activate:get() or "always"
	local var_294_3 = var_294_2 == "always"

	if var_294_2 == "conditions" and var_294_0.conditions then
		if var_294_0.conditions:get("standing") and var_294_1 == "standing" then
			var_294_3 = true
		end

		if var_294_0.conditions:get("running") and var_294_1 == "running" then
			var_294_3 = true
		end

		if var_294_0.conditions:get("air") and var_294_1 == "air" then
			var_294_3 = true
		end

		if var_294_0.conditions:get("air crouching") and var_294_1 == "air crouching" then
			var_294_3 = true
		end

		if var_294_0.conditions:get("crouching") and var_294_1 == "crouching" then
			var_294_3 = true
		end

		if var_294_0.conditions:get("sneaking") and var_294_1 == "sneaking" then
			var_294_3 = true
		end

		if var_294_0.conditions:get("slowwalk") and var_294_1 == "slowing" then
			var_294_3 = true
		end

		if var_294_0.conditions:get("quickpeek") then
			local var_294_4, var_294_5 = pcall(function()
				return bs_config.rage.main.double_tap:get()
			end)

			if var_294_4 and var_294_5 and rage.exploit:get() == 1 then
				var_294_3 = true
			end
		end
	end

	return var_294_3
end

function bs_break_lc.handle_normal(arg_296_0, arg_296_1)
	if not bs_break_lc.should_force(arg_296_0) then
		return false
	end

	local var_296_0 = bs_menu.antiaim.general.break_lc

	bs_v559:force()

	local var_296_1 = false

	pcall(function()
		local var_297_0 = bs_defensive_mgr and bs_defensive_mgr.get_debug_state and bs_defensive_mgr.get_debug_state() or nil

		var_296_1 = var_297_0 and var_297_0.defensive == true
	end)

	if not var_296_1 then
		local var_296_2 = false

		pcall(function()
			local var_298_0 = entity.get_local_player()
			local var_298_1 = var_298_0 and var_298_0.m_vecVelocity and var_298_0.m_vecVelocity:length2d() or 0

			var_296_2 = bs_config.rage.main.double_tap:get() or bs_config.rage.main.hide_shots:get() or var_298_1 < 1.11
		end)

		pcall(function()
			if bs_config.antiaim.fake_lag.limit_pui:get() < 14 then
				bs_config.antiaim.fake_lag.limit_pui:set(14)
			end
		end)

		if var_296_2 then
			bs_config.antiaim.fake_lag.enabled_pui:override(false)
		else
			bs_config.antiaim.fake_lag.enabled_pui:override()
		end
	else
		bs_config.antiaim.fake_lag.enabled_pui:override()
	end

	if arg_296_1 then
		arg_296_1.lag_options = "Always on"
		arg_296_1.hs_options = var_296_0.hide_shots:get()
	end

	return true
end

function bs_break_lc.update(arg_300_0, arg_300_1, arg_300_2)
	if not bs_break_lc.should_force(arg_300_0) then
		return
	end

	local var_300_0 = bs_menu.antiaim.general.break_lc

	bs_break_lc.handle_normal(arg_300_0, arg_300_1)

	arg_300_1.hs_options = var_300_0.hide_shots:get()
end

events.net_update_end(function()
	bs_v559:on_net_update_end()
end)

bs_auto_hide_shots = {}
bs_v571 = false
bs_auto_hide_shots.is_active = false

function bs_weapon_class(arg_302_0)
	if not arg_302_0 then
		return nil
	end

	local var_302_0 = arg_302_0:get_classname()
	local var_302_1 = arg_302_0:get_weapon_index()
	local var_302_2 = arg_302_0:get_weapon_info()

	if not var_302_2 then
		return nil
	end

	-- R8 Revolver (weapon_revolver, index 64, type 0) is a separate weapon from
	-- the Deagle. Detect it before the type-0/index-64 exclusion so the R8 Helper
	-- and per-weapon hitchance can target it independently.
	if var_302_1 == 64 or var_302_2.weapon_name == "weapon_revolver" then
		return "r8"
	end

	if var_302_2.weapon_type == 9 or var_302_2.weapon_type == 0 or var_302_1 == 64 then
		return nil
	end

	if var_302_0 == "CWeaponAWP" then
		return "awp"
	end

	if var_302_0 == "CWeaponSSG08" then
		return "scout"
	end

	if var_302_0 == "CWeaponSCAR20" or var_302_0 == "CWeaponG3SG1" then
		return "auto"
	end

	if var_302_1 == 1 or var_302_2 and var_302_2.is_revolver then
		return "deagle"
	end

	if var_302_2.weapon_type == 1 then
		return "pistol"
	end

	if var_302_2.full_auto then
		return "auto"
	end

	return nil
end

-- Resolve the local player's held weapon into a weapon-class key
-- ("awp"/"scout"/"deagle"/"pistol"/"auto") or nil for knives/grenades.
function bs_select_weapon_class()
	local lp = entity.get_local_player()
	if not lp or not lp:is_alive() then return nil end
	local w = nil
	local ok = pcall(function() w = lp:get_player_weapon() end)
	if not ok or not w then return nil end
	return bs_weapon_class(w)
end

function bs_v586()
	if bs_v571 then
		bs_config.rage.main.double_tap:override()
		bs_config.rage.main.hide_shots:override()

		bs_v571 = false
	end

	bs_auto_hide_shots.is_active = false
end

events.createmove(function()
	local var_304_0 = bs_menu.antiaim.general.ahs

	if not var_304_0 or not var_304_0.switch:get() then
		bs_v586()

		return
	end

	local var_304_1 = entity.get_local_player()

	if not var_304_1 or not var_304_1:is_alive() then
		bs_v586()

		return
	end

	local var_304_2

	if bs_v571 then
		var_304_2 = true
	else
		local var_304_3, var_304_4 = pcall(function()
			return bs_config.rage.main.double_tap:get()
		end)

		var_304_2 = var_304_3 and var_304_4
	end

	local var_304_5 = rage.exploit:get()
	local var_304_6 = var_304_1:get_player_weapon()
	local var_304_7 = bs_weapon_class(var_304_6)
	local var_304_8 = var_304_7 and var_304_0[var_304_7] and var_304_0[var_304_7]:get()
	local var_304_9 = var_304_7 and var_304_0[var_304_7 .. "_states"]
	local var_304_10 = bs_get_state.get()
	local var_304_11 = var_304_10 and var_304_9 and var_304_9:get(var_304_10)

	if var_304_8 and var_304_11 and var_304_2 and var_304_5 >= 1 then
		bs_config.rage.main.hide_shots:override(true)
		bs_config.rage.main.double_tap:override(false)

		bs_v571 = true
		bs_auto_hide_shots.is_active = true
	else
		bs_v586()
	end
end)
events.shutdown(bs_v586)
events.player_death(function(arg_306_0)
	local var_306_0 = entity.get_local_player()

	if var_306_0 and entity.get(arg_306_0.userid, true) == var_306_0 then
		bs_v586()
	end
end)
events.round_start(bs_v586)

bs_freestanding.side = false

function bs_v568()
	return bs_get_state.visual(bs_legit_aa.is_working) or bs_get_state.get(bs_legit_aa.is_working)
end

-- #############################################################################
-- #  [SEC-12] FREESTANDING
-- #############################################################################
function bs_freestanding.think(arg_308_0)
	bs_freestanding.active = false
	bs_freestanding.working = false

	if not (bs_menu.antiaim.angles.freestanding.switch:get() or bs_hotkeys:is_active("freestanding")) then
		return false
	end

	local var_308_0 = bs_v568()

	if var_308_0 == "legit aa" or bs_manual_yaw.think() then
		return false
	end

	local var_308_1 = bs_menu.antiaim.angles.freestanding

	if var_308_1.disablers then
		local var_308_2 = var_308_1.disablers

		if (var_308_0 == "air" or var_308_0 == "air crouching") and var_308_2:get("air") then
			return false
		end

		if var_308_0 == "slowing" and var_308_2:get("slowwalk") then
			return false
		end

		if (var_308_0 == "crouching" or var_308_0 == "sneaking") and var_308_2:get("crouch") then
			return false
		end

		if var_308_0 == "running" and var_308_2:get("move") then
			return false
		end
	end

	bs_freestanding.active = true
	bs_freestanding.working = rage.antiaim:get_target(true) ~= nil

	return true
end

function bs_freestanding.get_side(arg_309_0)
	local var_309_0 = entity.get_threat(true) or entity.get_threat()

	if not var_309_0 then
		bs_freestanding.side = false

		return
	end

	if not bs_freestanding.think(arg_309_0) then
		bs_freestanding.side = false

		return
	end

	local var_309_1 = bs_defensive_mgr and bs_defensive_mgr.get_debug_state and bs_defensive_mgr.get_debug_state() or {}

	if arg_309_0 and arg_309_0.choked_commands ~= 0 or var_309_1.defensive then
		return
	end

	local var_309_2 = entity.get_local_player()

	if not var_309_2 or not var_309_2:is_alive() then
		bs_freestanding.side = false

		return
	end

	local var_309_3, var_309_4 = pcall(function()
		local var_310_0 = var_309_2:get_origin():to(var_309_0:get_origin()):angles().y
		local var_310_1 = var_309_2.m_flLowerBodyYawTarget - var_310_0 + 180

		while var_310_1 > 180 do
			var_310_1 = var_310_1 - 360
		end

		while var_310_1 < -180 do
			var_310_1 = var_310_1 + 360
		end

		return var_310_1
	end)

	if not var_309_3 or not var_309_4 then
		bs_freestanding.side = false

		return
	end

	if var_309_4 < 91 and var_309_4 > 89 then
		bs_freestanding.side = "right"
	elseif var_309_4 > -91 and var_309_4 < -89 then
		bs_freestanding.side = "left"
	else
		bs_freestanding.side = false
	end
end

function bs_freestanding.update(arg_311_0, arg_311_1, arg_311_2)
	if not entity.get_local_player() then
		return
	end

	arg_311_1.freestanding = true

	bs_config.antiaim.angles.disable_yaw_modifiers:override(true)
	bs_config.antiaim.angles.body_freestanding:override(false)

	arg_311_1.yaw_offset = 0
	arg_311_1.yaw_modifier = "Disabled"
	arg_311_1.modifier_offset = 0
	arg_311_1.body_yaw = true

	local var_311_1 = arg_311_2 and arg_311_2.left_limit and arg_311_2.left_limit:get() or arg_311_2 and arg_311_2.fake_limit and arg_311_2.fake_limit:get() or 60

	arg_311_1.right_limit, arg_311_1.left_limit = arg_311_2 and arg_311_2.right_limit and arg_311_2.right_limit:get() or arg_311_2 and arg_311_2.fake_limit and arg_311_2.fake_limit:get() or 60, var_311_1
	arg_311_1.freestand_peek = "off"
	arg_311_1.body_freestanding = false
	arg_311_1.disable_yaw_modifiers = true
end

bs_v567 = nil
bs_v577 = ""
bs_v585 = 0
bs_defensive_mgr = {}
bs_defensive_mgr.is_active = false
bs_v591 = {
	active_until = 0,
	active = false,
	ticks = 0,
	active2 = false
}
bs_v598 = false
bs_v608 = 0
bs_v618 = 0

events.net_update_end(function()
	local var_312_0, var_312_1 = pcall(function()
		return rage.exploit:get()
	end)

	bs_v598 = var_312_0 and var_312_1 == 1

	if not bs_v598 then
		bs_v591.active = false
		bs_v591.active_until = 0
		bs_v591.ticks = 0
	end
end)
events.level_change(function()
	bs_v608 = 0
	bs_v618 = 0
	bs_v591.active = false
	bs_v591.active_until = 0
	bs_v591.ticks = 0
	bs_v591.active2 = false
end)
events.createmove(function(arg_315_0)
	local var_315_0 = entity.get_local_player()

	if not var_315_0 or not var_315_0:is_alive() then
		return
	end

	local var_315_1 = var_315_0.m_nTickBase
	local var_315_2 = globals.server_tick
	local var_315_3 = var_315_1 - bs_v608

	bs_v608 = math.max(var_315_1, bs_v608)

	if var_315_3 > 1 then
		bs_v618 = var_315_2 + 1
		bs_v591.active_until = 0
	elseif var_315_3 < 0 then
		bs_v591.ticks = -var_315_3
		bs_v591.active_until = var_315_2 - var_315_3 - 4
	elseif bs_v618 == var_315_2 then
		bs_v591.active_until = var_315_2 + 1
	end

	bs_v591.active = var_315_2 <= bs_v591.active_until
	bs_v591.active2 = bs_is_defensive()
end)

-- #############################################################################
-- #  [SEC-13] DEFENSIVE MANAGER
-- #############################################################################
function bs_defensive_mgr.get_debug_state()
	return {
		hidden = bs_defensive_mgr.is_active,
		defensive = bs_v591.active,
		defensive_c = bs_v591.active2,
		match = bs_v591.active == bs_v591.active2,
		ticks = bs_v591.ticks,
		charged = bs_v598
	}
end

bs_v635 = {}

for iter_0_15, iter_0_16 in ipairs(bs_states.states) do
	if iter_0_16 ~= "legit aa" then
		bs_v635[#bs_v635 + 1] = iter_0_16
	end
end

bs_v635[#bs_v635 + 1] = "manual aa"
bs_v635[#bs_v635 + 1] = "safe head"
bs_v635[#bs_v635 + 1] = "freestanding"
bs_v648 = {}
bs_v656 = {}
bs_v664 = {}

for iter_0_17, iter_0_18 in ipairs(bs_v635) do
	bs_v648[iter_0_18] = 0
	bs_v656[iter_0_18] = false
	bs_v664[iter_0_18] = 0
end

bs_v673 = {}
bs_v681 = {}
bs_v690 = {}
bs_v701 = {}
bs_v711 = {}

for iter_0_19, iter_0_20 in ipairs(bs_v635) do
	bs_v673[iter_0_20] = 0
	bs_v681[iter_0_20] = 0
	bs_v690[iter_0_20] = 0
	bs_v701[iter_0_20] = 0
	bs_v711[iter_0_20] = 0
end

bs_v722 = {}

for iter_0_21, iter_0_22 in ipairs(bs_v635) do
	bs_v722[iter_0_22] = 0
end

bs_v735 = {}
bs_v747 = {}

for iter_0_23, iter_0_24 in ipairs(bs_v635) do
	bs_v735[iter_0_24] = false
	bs_v747[iter_0_24] = 0
end

bs_v757 = {}

for iter_0_25, iter_0_26 in ipairs(bs_v635) do
	bs_v757[iter_0_26] = 0
end

bs_v767 = {}
bs_v14 = {}

for iter_0_27, iter_0_28 in ipairs(bs_v635) do
	bs_v767[iter_0_28] = 0
	bs_v14[iter_0_28] = 0
end

bs_v17 = {}
bs_v41 = {}
bs_v44 = {}
bs_v59 = {}

for iter_0_29, iter_0_30 in ipairs(bs_v635) do
	bs_v17[iter_0_30] = 0
	bs_v41[iter_0_30] = 0
	bs_v44[iter_0_30] = false
	bs_v59[iter_0_30] = 0
end

bs_v74 = {}

for iter_0_31, iter_0_32 in ipairs(bs_v635) do
	bs_v74[iter_0_32] = {
		notified = false,
		reset_dur = 3,
		reset_time = 0,
		yaw_extra = 0,
		pitch_flipped = false
	}
end

bs_v89 = {}
bs_v104 = {}
bs_v120 = {}

function bs_v137(arg_317_0)
	while arg_317_0 > 180 do
		arg_317_0 = arg_317_0 - 360
	end

	while arg_317_0 < -180 do
		arg_317_0 = arg_317_0 + 360
	end

	return arg_317_0
end

function bs_v155(arg_318_0, arg_318_1, arg_318_2)
	local var_318_0 = arg_318_2 * math.pi / 180

	return vector(arg_318_0.x + math.cos(var_318_0) * arg_318_1, arg_318_0.y + math.sin(var_318_0) * arg_318_1, arg_318_0.z)
end

events.player_hurt(function(arg_319_0)
	local var_319_0 = entity.get_local_player()

	if not var_319_0 or not var_319_0:is_alive() then
		return
	end

	local var_319_1 = entity.get(arg_319_0.userid, true)
	local var_319_2 = entity.get(arg_319_0.attacker, true)

	if not var_319_2 or not var_319_2:is_enemy() or var_319_1 ~= var_319_0 then
		return
	end

	local var_319_3 = {
		"knife",
		"hegrenade",
		"inferno",
		"flashbang",
		"decoy",
		"smokegrenade",
		"taser"
	}

	for iter_319_0, iter_319_1 in ipairs(var_319_3) do
		if arg_319_0.weapon == iter_319_1 then
			return
		end
	end

	local var_319_4 = var_319_2:get_index()
	local var_319_5, var_319_6 = pcall(function()
		return var_319_2:get_name()
	end)

	bs_v104[var_319_4] = {
		name = var_319_5 and var_319_6 or "?",
		time = globals.curtime
	}
end)
events.bullet_impact(function(arg_321_0)
	local var_321_0 = entity.get_local_player()

	if not var_321_0 or not var_321_0:is_alive() then
		return
	end

	local var_321_1 = entity.get(arg_321_0.userid, true)

	if not var_321_1 or not var_321_1:is_enemy() or not var_321_1:is_alive() or var_321_1:is_dormant() then
		return
	end

	local var_321_2 = var_321_1:get_index()
	local var_321_3 = var_321_0.m_vecOrigin
	local var_321_4 = var_321_1.m_vecOrigin
	local var_321_5 = math.atan(var_321_3.y - var_321_4.y, var_321_3.x - var_321_4.x) * 180 / math.pi
	local var_321_6 = var_321_0:get_origin() + var_321_0.m_vecViewOffset
	local var_321_7 = var_321_1:get_origin() + var_321_1.m_vecViewOffset
	local var_321_8 = vector(arg_321_0.x, arg_321_0.y, arg_321_0.z)
	local var_321_9 = bs_v155(var_321_6, 16, bs_v137(var_321_5 - 45 + 180))
	local var_321_10 = bs_v155(var_321_6, 16, bs_v137(var_321_5 + 45 + 180))
	local var_321_11 = var_321_9:closest_ray_point(var_321_7, var_321_8)
	local var_321_12 = var_321_10:closest_ray_point(var_321_7, var_321_8)

	if var_321_11:dist(var_321_9) < 70 or var_321_12:dist(var_321_10) < 70 then
		local var_321_13, var_321_14 = pcall(function()
			return var_321_1:get_name()
		end)

		bs_v89[var_321_2] = {
			name = var_321_13 and var_321_14 or "?",
			time = globals.curtime
		}
	end
end)
events.render(function()
	local var_323_0 = entity.get_local_player()

	if not var_323_0 or not var_323_0:is_alive() then
		return
	end

	bs_iter_players(true, true, function(arg_324_0)
		local var_324_0 = arg_324_0:get_index()

		local function var_324_1(arg_325_0, arg_325_1)
			if bs_legit_aa.is_working then
				return
			end

			local var_325_0 = bs_get_state.get(bs_legit_aa.is_working)

			if not var_325_0 then
				return
			end

			local var_325_1 = bs_menu.antiaim.defensive

			if not var_325_1 or not var_325_1.settings then
				return
			end

			local var_325_2 = var_325_1.active_on:get("doubletap")
			local var_325_3 = var_325_1.active_on:get("hideshots")

			if var_325_2 or var_325_3 then
				local var_325_4, var_325_5 = pcall(function()
					return bs_config.rage.main.double_tap:get()
				end)
				local var_325_6, var_325_7 = pcall(function()
					return bs_config.rage.main.hide_shots:get()
				end)

				if (not var_325_2 or not var_325_4 or not var_325_5) and (not var_325_3 or not var_325_6 or not var_325_7) then
					return
				end
			end

			local var_325_8 = bs_safe_head.think(nil)
			local var_325_9 = bs_manual_yaw.think()
			local var_325_10 = bs_freestanding.think()
			local var_325_11
			local var_325_12 = var_325_8 and "safe head" or var_325_9 and "manual aa" or var_325_10 and "freestanding" or var_325_0
			local var_325_13 = var_325_1.settings[var_325_12]

			if not var_325_13 or not var_325_13.enable:get() then
				return
			end

			if not var_325_13.def_abf or not var_325_13.def_abf:get() then
				return
			end

			local var_325_14 = var_325_13.def_abf_trigger and var_325_13.def_abf_trigger:get() or "miss"

			if arg_325_1 and var_325_14 == "miss" then
				return
			end

			if not arg_325_1 and var_325_14 == "hit" then
				return
			end

			local var_325_15 = bs_v74[var_325_12]

			if var_325_15.reset_time > 0 and globals.realtime >= var_325_15.reset_time then
				var_325_15.yaw_extra = 0
				var_325_15.pitch_flipped = false
				var_325_15.reset_time = 0
				var_325_15.notified = false
				bs_defensive_mgr.def_ind_latch.is_working = false
				bs_defensive_mgr.def_ind_latch.reset_time = 0
				bs_defensive_mgr.def_ind_latch.triggered_state = nil

				return
			end

			local var_325_16 = var_325_13.def_abf_mode:get()

			if var_325_16 == "flip yaw" then
				var_325_15.yaw_extra = var_325_15.yaw_extra == 0 and 180 or 0
			elseif var_325_16 == "flip pitch" then
				var_325_15.pitch_flipped = not var_325_15.pitch_flipped
			elseif var_325_16 == "random yaw" then
				var_325_15.yaw_extra = math.random(-180, 180)
			end

			var_325_15.reset_dur = var_325_13.def_abf_reset:get()
			var_325_15.reset_time = globals.realtime + var_325_15.reset_dur
			bs_defensive_mgr.def_ind_latch.is_working = true
			bs_defensive_mgr.def_ind_latch.reset_time = var_325_15.reset_time
			bs_defensive_mgr.def_ind_latch.reset_dur = var_325_15.reset_dur
			bs_defensive_mgr.def_ind_latch.triggered_state = var_325_12

			if var_325_13.def_abf_notify and var_325_13.def_abf_notify:get() and not var_325_15.notified then
				var_325_15.notified = true

				bs_v567(arg_325_0.name, arg_325_1, true)
			end
		end

		if bs_v104[var_324_0] then
			local var_324_2 = bs_v104[var_324_0]

			if bs_v120[var_324_0] == var_324_2.time then
				bs_v104[var_324_0] = nil
				bs_v89[var_324_0] = nil

				return
			end

			bs_v120[var_324_0] = var_324_2.time

			var_324_1(var_324_2, true)

			bs_v104[var_324_0] = nil
			bs_v89[var_324_0] = nil
		end

		if bs_v89[var_324_0] then
			local var_324_3 = bs_v89[var_324_0]

			if bs_v120[var_324_0] == var_324_3.time then
				bs_v89[var_324_0] = nil

				return
			end

			bs_v120[var_324_0] = var_324_3.time

			var_324_1(var_324_3, false)

			bs_v89[var_324_0] = nil
		end
	end)
end)

function bs_v180(arg_328_0, arg_328_1, arg_328_2, arg_328_3, arg_328_4)
	local var_328_0 = math.max(1, arg_328_1)
	local var_328_1 = arg_328_0 % var_328_0 / var_328_0
	local var_328_2

	if arg_328_4 == "sine" then
		var_328_2 = (math.sin(var_328_1 * math.pi * 2 - math.pi * 0.5) + 1) * 0.5
	elseif arg_328_4 == "triangle" then
		var_328_2 = var_328_1 < 0.5 and var_328_1 * 2 or (1 - var_328_1) * 2
	elseif arg_328_4 == "step" then
		var_328_2 = var_328_1 < 0.5 and 0 or 1
	elseif arg_328_4 == "bounce" then
		local var_328_3 = math.sin(var_328_1 * math.pi)

		var_328_2 = var_328_3 * var_328_3
	else
		var_328_2 = var_328_1
	end

	return arg_328_2 + var_328_2 * (arg_328_3 - arg_328_2)
end

bs_v203 = {}
bs_v221 = {}
bs_v241 = {}
bs_v260 = {}
bs_v275 = {}
bs_v289 = {}
bs_v303 = {}
bs_v316 = {}

for iter_0_33, iter_0_34 in ipairs(bs_v635) do
	bs_v203[iter_0_34] = 0
	bs_v221[iter_0_34] = 0
	bs_v241[iter_0_34] = 0
	bs_v260[iter_0_34] = 0
	bs_v275[iter_0_34] = 0
	bs_v289[iter_0_34] = false
	bs_v303[iter_0_34] = 0
	bs_v316[iter_0_34] = 0
end

function bs_v328(arg_329_0)
	local var_329_0 = bs_v74[arg_329_0]

	if var_329_0 then
		var_329_0.yaw_extra = 0
		var_329_0.pitch_flipped = false
		var_329_0.reset_time = 0
		var_329_0.notified = false
	end

	bs_v747[arg_329_0] = 0
	bs_v735[arg_329_0] = false
	bs_v701[arg_329_0] = 0
	bs_v17[arg_329_0] = 0
	bs_v41[arg_329_0] = 0
	bs_v44[arg_329_0] = false
	bs_v767[arg_329_0] = 0
	bs_v14[arg_329_0] = 0
	bs_v241[arg_329_0] = 0
	bs_v260[arg_329_0] = 0
	bs_v275[arg_329_0] = 0
	bs_v289[arg_329_0] = false
	bs_v303[arg_329_0] = 0
	bs_v316[arg_329_0] = 0
end

-- Game Events Defensive lifecycle tracking
bs_defensive_mgr.game_events_was_active = false
bs_defensive_mgr.game_events_armed = true  -- allows fresh duration on first event
bs_defensive_mgr.game_events_hold = 0       -- remaining hold ticks (choked-commands-aware)
bs_defensive_mgr.game_events_last_signal = false  -- for rising-edge detection

function bs_defensive_mgr.reset_game_events_state()
	bs_v316["game events"] = 0
	bs_defensive_mgr.game_events_was_active = false
	bs_defensive_mgr.game_events_armed = true
	bs_defensive_mgr.game_events_hold = 0
	bs_defensive_mgr.game_events_last_signal = false
end

function bs_v341(arg_330_0, arg_330_1, arg_330_2, arg_330_3)
	if arg_330_0 == "off" then
		return nil
	end

	if arg_330_0 == "down" then
		return arg_330_3 and -89 or 89
	end

	if arg_330_0 == "up" then
		return arg_330_3 and 89 or -89
	end

	if arg_330_0 == "random" then
		return math.random() > 0.5 and math.random(-89, 60) or -math.random(-89, 60)
	end

	if arg_330_0 == "custom" then
		return arg_330_1.pitch:get()
	end

	if arg_330_0 == "bluesense" then
		return math.map(math.abs(globals.realtime % 0.3 - 0.15), 0, 0.15, -89, 89)
	end

	if arg_330_0 == "semi-up" then
		return arg_330_3 and 52 or -52
	end

	if arg_330_0 == "semi-down" then
		return arg_330_3 and -52 or 52
	end

	if arg_330_0 == "dynamic" then
		bs_v767[arg_330_2] = (bs_v767[arg_330_2] or 0) + 1

		local var_330_0 = arg_330_1.dyn_pitch_min and arg_330_1.dyn_pitch_min:get() or -89
		local var_330_1 = arg_330_1.dyn_pitch_max and arg_330_1.dyn_pitch_max:get() or 89
		local var_330_2 = arg_330_1.dyn_pitch_spd and arg_330_1.dyn_pitch_spd:get() or 60
		local var_330_3 = arg_330_1.dyn_pitch_mode and arg_330_1.dyn_pitch_mode:get() or "sine"
		local var_330_4 = arg_330_1.dyn_pitch_rand and arg_330_1.dyn_pitch_rand:get() or 0
		local var_330_5 = bs_v180(bs_v767[arg_330_2], var_330_2, var_330_0, var_330_1, var_330_3)

		if var_330_4 > 0 then
			var_330_5 = var_330_5 + math.random(-var_330_4, var_330_4)
		end

		local var_330_6 = math.max(-89, math.min(89, var_330_5))
		local var_330_7 = math.max(0.01, math.min(1, var_330_2 / 200))

		bs_v221[arg_330_2] = (bs_v221[arg_330_2] or 0) + (var_330_6 - (bs_v221[arg_330_2] or 0)) * var_330_7

		return math.max(-89, math.min(89, bs_v221[arg_330_2]))
	end

	if arg_330_0 == "oscillate" then
		bs_v260[arg_330_2] = (bs_v260[arg_330_2] or 0) + 1

		local var_330_8 = arg_330_1.osc_pitch_a and arg_330_1.osc_pitch_a:get() or -89
		local var_330_9 = arg_330_1.osc_pitch_b and arg_330_1.osc_pitch_b:get() or 89
		local var_330_10 = arg_330_1.osc_pitch_rate and arg_330_1.osc_pitch_rate:get() or 6
		local var_330_11 = arg_330_1.osc_pitch_rand and arg_330_1.osc_pitch_rand:get() or 0
		local var_330_12 = var_330_10 > (bs_v260[arg_330_2] or 0) % (var_330_10 * 2) and var_330_8 or var_330_9

		if var_330_11 > 0 then
			var_330_12 = var_330_12 + math.random(-var_330_11, var_330_11)
		end

		return math.max(-89, math.min(89, var_330_12))
	end

	return nil
end

function bs_v355()
	local var_331_0 = entity.get_local_player()

	if not var_331_0 or not var_331_0:is_alive() then
		return nil
	end

	local var_331_1 = entity.get_threat(true) or entity.get_threat()

	if not var_331_1 then
		return nil
	end

	local var_331_2 = var_331_0:get_origin()
	local var_331_3 = 0

	pcall(function()
		local var_332_0 = var_331_0:get_anim_state()

		if var_332_0 then
			var_331_3 = var_332_0.foot_yaw
		end
	end)

	local var_331_4, var_331_5 = pcall(function()
		return var_331_1:get_origin() - var_331_2
	end)

	if not var_331_4 or not var_331_5 then
		return nil
	end

	local var_331_6 = math.deg(math.atan2(var_331_5.y, var_331_5.x)) - var_331_3

	while var_331_6 > 180 do
		var_331_6 = var_331_6 - 360
	end

	while var_331_6 < -180 do
		var_331_6 = var_331_6 + 360
	end

	return var_331_6 >= 0
end

function bs_v374(arg_334_0, arg_334_1, arg_334_2, arg_334_3, arg_334_4)
	arg_334_3 = arg_334_3 or 0

	if arg_334_0 == "off" then
		return nil
	end

	if arg_334_0 == "static" then
		return arg_334_1.yaw:get() + arg_334_3
	end

	if arg_334_0 == "sideways" then
		return (rage.antiaim:inverter() and -90 or 90) + arg_334_3
	end

	if arg_334_0 == "random" then
		return math.random(-180, 180)
	end

	if arg_334_0 == "opposite" then
		return 180 + arg_334_3
	end

	if arg_334_0 == "flip" then
		bs_v1038 = arg_334_1.yaw_lr_left and arg_334_1.yaw_lr_left:get() or 0
		bs_v1043 = arg_334_1.yaw_lr_right and arg_334_1.yaw_lr_right:get() or 0
		bs_v1048 = arg_334_1.yaw_lr_dt and arg_334_1.yaw_lr_dt:get() or 6
		bs_v1053 = arg_334_1.yaw_lr_rand and arg_334_1.yaw_lr_rand:get() or 0
		bs_v1058 = bs_v1048

		if arg_334_1.def_flip_adaptive and arg_334_1.def_flip_adaptive:get() then
			bs_v1023 = arg_334_1.def_flip_adp_var and arg_334_1.def_flip_adp_var:get() or 3
			bs_v1058 = math.max(1, bs_v1048 + utils.random_int(-bs_v1023, bs_v1023))
		end

		if arg_334_4 then
			bs_v747[arg_334_2] = (bs_v747[arg_334_2] or 0) + 1

			if bs_v1058 <= bs_v747[arg_334_2] then
				bs_v747[arg_334_2] = 0
				bs_v735[arg_334_2] = not bs_v735[arg_334_2]
			end
		end

		bs_v1022 = bs_v735[arg_334_2] and bs_v1038 or bs_v1043

		if bs_v1053 > 0 then
			bs_v1022 = bs_v1022 + math.random(-bs_v1053, bs_v1053)
		end

		return math.max(-60, math.min(60, bs_v1022)) + arg_334_3
	end

	if arg_334_0 == "spin" then
		bs_v1037 = arg_334_1.yaw_spin_spd and arg_334_1.yaw_spin_spd:get() or 1
		bs_v1042 = arg_334_1.yaw_spin_from and arg_334_1.yaw_spin_from:get() or -180
		bs_v1047 = arg_334_1.yaw_spin_to and arg_334_1.yaw_spin_to:get() or 180
		bs_v1052 = arg_334_1.yaw_spin_rand and arg_334_1.yaw_spin_rand:get() or 0
		bs_v701[arg_334_2] = (bs_v701[arg_334_2] or 0) + bs_v1037
		bs_v1057 = bs_v1047 - bs_v1042

		if bs_v1057 == 0 then
			return bs_v1042 + arg_334_3
		end

		bs_v1027 = bs_v1042 + bs_v701[arg_334_2] % 360 / 360 * bs_v1057

		if bs_v1052 > 0 then
			bs_v1027 = bs_v1027 + math.random(-bs_v1052, bs_v1052)
		end

		return bs_v1027 + arg_334_3
	end

	if arg_334_0 == "dynamic" then
		bs_v14[arg_334_2] = (bs_v14[arg_334_2] or 0) + 1
		bs_v1036 = arg_334_1.dyn_yaw_min and arg_334_1.dyn_yaw_min:get() or -180
		bs_v1041 = arg_334_1.dyn_yaw_max and arg_334_1.dyn_yaw_max:get() or 180
		bs_v1046 = arg_334_1.dyn_yaw_spd and arg_334_1.dyn_yaw_spd:get() or 60
		bs_v1051 = arg_334_1.dyn_yaw_mode and arg_334_1.dyn_yaw_mode:get() or "sine"
		bs_v1056 = arg_334_1.dyn_yaw_rand and arg_334_1.dyn_yaw_rand:get() or 0
		bs_v1021 = bs_v180(bs_v14[arg_334_2], bs_v1046, bs_v1036, bs_v1041, bs_v1051)

		if bs_v1056 > 0 then
			bs_v1021 = bs_v1021 + math.random(-bs_v1056, bs_v1056)
		end

		bs_v1026 = math.max(0.01, math.min(1, bs_v1046 / 200))
		bs_v203[arg_334_2] = (bs_v203[arg_334_2] or 0) + (bs_v1021 - (bs_v203[arg_334_2] or 0)) * bs_v1026

		return bs_v203[arg_334_2] + arg_334_3
	end

	if arg_334_0 == "jitter" then
		bs_v241[arg_334_2] = (bs_v241[arg_334_2] or 0) + 1
		bs_v1035 = arg_334_1.def_jitter_base and arg_334_1.def_jitter_base:get() or 0
		bs_v1040 = arg_334_1.def_jitter_range and arg_334_1.def_jitter_range:get() or 40
		bs_v1045 = arg_334_1.def_jitter_speed and arg_334_1.def_jitter_speed:get() or 3
		bs_v1050 = arg_334_1.def_jitter_style and arg_334_1.def_jitter_style:get() or "sine"
		bs_v1055 = arg_334_1.def_jitter_phase and arg_334_1.def_jitter_phase:get() or 0
		bs_v1020 = 0
		bs_v1025 = math.max(1, bs_v1045) * 2
		bs_v1029 = bs_v241[arg_334_2] % bs_v1025 / bs_v1025
		bs_v1031 = bs_v1055 * math.pi / 180

		if bs_v1050 == "sine" then
			bs_v1020 = math.sin(bs_v1029 * math.pi * 2 + bs_v1031) * bs_v1040
		elseif bs_v1050 == "triangle" then
			bs_v1033 = bs_v1029 * 2

			if bs_v1033 > 1 then
				bs_v1033 = 2 - bs_v1033
			end

			bs_v1020 = (bs_v1033 * 2 - 1) * bs_v1040
		elseif bs_v1050 == "bounce" then
			bs_v1032 = bs_v1029 * 2

			if bs_v1032 > 1 then
				bs_v1032 = 2 - bs_v1032
			end

			bs_v1020 = (bs_v1032 * 2 - 1) * bs_v1040
		elseif bs_v1050 == "step" then
			bs_v1020 = bs_v1029 < 0.5 and bs_v1040 or -bs_v1040
		elseif bs_v1050 == "noise" then
			bs_v1020 = math.random(-math.floor(bs_v1040), math.floor(bs_v1040))
		end

		return bs_v1035 + bs_v1020 + arg_334_3
	end

	if arg_334_0 == "sweep" then
		bs_v275[arg_334_2] = (bs_v275[arg_334_2] or 0) + 1
		bs_v1034 = arg_334_1.sweep_from and arg_334_1.sweep_from:get() or -90
		bs_v1039 = arg_334_1.sweep_to and arg_334_1.sweep_to:get() or 90
		bs_v1044 = arg_334_1.sweep_rate and arg_334_1.sweep_rate:get() or 6
		bs_v1049 = arg_334_1.sweep_hold and arg_334_1.sweep_hold:get() or 2
		bs_v1054 = arg_334_1.sweep_rand and arg_334_1.sweep_rand:get() or 0
		bs_v1019 = bs_v1044 + bs_v1049
		bs_v1024 = (bs_v275[arg_334_2] or 0) % (bs_v1019 * 2)
		bs_v1028 = nil

		if bs_v1024 < bs_v1044 then
			bs_v1028 = bs_v1034 + (bs_v1039 - bs_v1034) * (bs_v1024 / math.max(1, bs_v1044 - 1))
		elseif bs_v1024 < bs_v1019 then
			bs_v1028 = bs_v1039
		elseif bs_v1024 < bs_v1019 + bs_v1044 then
			bs_v1030 = (bs_v1024 - bs_v1019) / math.max(1, bs_v1044 - 1)
			bs_v1028 = bs_v1039 + (bs_v1034 - bs_v1039) * bs_v1030
		else
			bs_v1028 = bs_v1034
		end

		if bs_v1054 > 0 then
			bs_v1028 = bs_v1028 + math.random(-bs_v1054, bs_v1054)
		end

		return bs_v1028 + arg_334_3
	end

	return nil
end

function bs_defensive_mgr.get_abf_state(arg_335_0)
	return bs_v74[arg_335_0]
end

bs_defensive_mgr.def_ind_latch = {
	is_working = false,
	reset_dur = 3,
	reset_time = 0
}
	bs_defensive_mgr.head_vuln_ticks = 0
	bs_defensive_mgr.safe_head_hold = 0

function bs_defensive_mgr.update(arg_336_0, arg_336_1, arg_336_2, arg_336_3)
	if bs_legit_aa.is_working then
		bs_defensive_mgr.is_active = false

		rage.antiaim:override_hidden_pitch(0)
		rage.antiaim:override_hidden_yaw_offset(0)

		return false
	end

	local var_336_0 = bs_menu.antiaim.defensive

	local function var_336_1()
		bs_defensive_mgr.is_active = false

		rage.antiaim:override_hidden_pitch(0)
		rage.antiaim:override_hidden_yaw_offset(0)
	end

	local var_336_2 = bs_manual_yaw.think()
	local var_336_3 = bs_freestanding.think()
	local var_336_4

	var_336_4 = arg_336_3 or var_336_2 or var_336_3

	if not var_336_0 or not var_336_0.settings then
		var_336_1()

		return false
	end

	local var_336_5 = bs_break_lc.think(arg_336_0)
	local var_336_6 = var_336_0.active_on:get("doubletap")
	local var_336_7 = var_336_0.active_on:get("hideshots")

	if not var_336_5 and (var_336_6 or var_336_7) then
		local var_336_8, var_336_9 = pcall(function()
			return bs_config.rage.main.double_tap:get()
		end)
		local var_336_10, var_336_11 = pcall(function()
			return bs_config.rage.main.hide_shots:get()
		end)
		local var_336_12 = var_336_10 and var_336_11 or bs_auto_hide_shots.is_active

		if (not var_336_6 or not var_336_8 or not var_336_9) and (not var_336_7 or not var_336_12) then
			var_336_1()

			return false
		end
	end

local var_336_13
		local var_336_14 = arg_336_2 == "game events" and "game events" or arg_336_3 and "safe head" or var_336_2 and "manual aa" or var_336_3 and "freestanding" or arg_336_2
		local var_336_15 = var_336_0.settings[var_336_14]

		-- Sustain: once defensive triggers on safe head, hold it for a few ticks
		-- even if the safe head check flickers on/off between frames
		if var_336_14 == "safe head" and arg_336_3 then
			bs_defensive_mgr.safe_head_hold = 4
		end
		if bs_defensive_mgr.safe_head_hold and bs_defensive_mgr.safe_head_hold > 0 then
			bs_defensive_mgr.safe_head_hold = bs_defensive_mgr.safe_head_hold - 1
			if bs_defensive_mgr.safe_head_hold > 0 and not arg_336_3 then
				var_336_14 = "safe head"
				var_336_15 = var_336_0.settings["safe head"]
			end
		end

		-- Game Events Defensive lifecycle: track activation/expire to give each event a fresh duration
		-- Respect the hold timer managed in CreateMove; do not reset while hold is active.
		local var_336_13_is_ge = (var_336_14 == "game events")
		local var_336_13_hold_active = bs_defensive_mgr.game_events_hold and bs_defensive_mgr.game_events_hold > 0
		if var_336_13_is_ge then
			if not bs_defensive_mgr.game_events_was_active and bs_defensive_mgr.game_events_armed and not var_336_13_hold_active then
				bs_v316["game events"] = 0
				bs_defensive_mgr.game_events_armed = false
			end
			bs_defensive_mgr.game_events_was_active = true
		else
			if bs_defensive_mgr.game_events_was_active and not var_336_13_hold_active then
				bs_defensive_mgr.game_events_armed = true
				bs_v316["game events"] = 0
				bs_defensive_mgr.game_events_was_active = false
			end
		end

		if not var_336_15 or not var_336_15.enable:get() then
		var_336_1()

		return false
	end

	if var_336_15.activation_mode:get() == "hittable only" and not bs_safe_head.threat_can_hit_head(entity.get_threat(true) or entity.get_threat()) then
		var_336_1()

		return false
	end

	local var_336_16 = bs_v74[var_336_14]

	if not var_336_15.def_abf or not var_336_15.def_abf:get() then
		if var_336_16 then
			var_336_16.yaw_extra = 0
			var_336_16.pitch_flipped = false
			var_336_16.reset_time = 0
			var_336_16.notified = false
		end

		if bs_defensive_mgr.def_ind_latch.triggered_state == var_336_14 then
			bs_defensive_mgr.def_ind_latch.is_working = false
			bs_defensive_mgr.def_ind_latch.reset_time = 0
			bs_defensive_mgr.def_ind_latch.triggered_state = nil
		end
	end

	if var_336_16 and var_336_16.reset_time > 0 and globals.realtime >= var_336_16.reset_time then
		var_336_16.yaw_extra = 0
		var_336_16.pitch_flipped = false
		var_336_16.reset_time = 0
		var_336_16.notified = false
	end

	bs_config.antiaim.angles.hidden:override(true)

	bs_defensive_mgr.is_active = true

	local var_336_17 = var_336_15.def_duration and var_336_15.def_duration:get() or 0

	if var_336_17 > 0 then
		if var_336_17 > (bs_v316[var_336_14] or 0) then
			bs_v316[var_336_14] = (bs_v316[var_336_14] or 0) + 1
		end

		if var_336_17 <= bs_v316[var_336_14] then
			var_336_1()

			return false
		end
	else
		bs_v316[var_336_14] = 0
	end

	local var_336_18 = var_336_16 and var_336_16.pitch_flipped or false
	local var_336_19 = bs_v341(var_336_15.pitch_mode:get(), var_336_15, var_336_14, var_336_18)

	rage.antiaim:override_hidden_pitch(var_336_19 ~= nil and var_336_19 or 0)

	local var_336_20 = var_336_16 and var_336_16.yaw_extra or 0
	local var_336_21 = arg_336_0.choked_commands == 0
	local var_336_22 = bs_v374(var_336_15.yaw_mode:get(), var_336_15, var_336_14, var_336_20, var_336_21)

	rage.antiaim:override_hidden_yaw_offset(var_336_22 ~= nil and var_336_22 or 0)

	return false
end

function bs_v384()
	for iter_340_0, iter_340_1 in ipairs(bs_v635) do
		local var_340_0 = bs_v74[iter_340_1]

		if var_340_0 then
			var_340_0.yaw_extra = 0
			var_340_0.pitch_flipped = false
			var_340_0.reset_time = 0
			var_340_0.notified = false
		end

		bs_v747[iter_340_1] = 0
		bs_v735[iter_340_1] = false
		bs_v701[iter_340_1] = 0
		bs_v17[iter_340_1] = 0
		bs_v41[iter_340_1] = 0
		bs_v44[iter_340_1] = false
		bs_v767[iter_340_1] = 0
		bs_v14[iter_340_1] = 0
		bs_v241[iter_340_1] = 0
		bs_v260[iter_340_1] = 0
		bs_v275[iter_340_1] = 0
		bs_v289[iter_340_1] = false
		bs_v303[iter_340_1] = 0
		bs_v316[iter_340_1] = 0
	end

	bs_defensive_mgr.def_ind_latch.is_working = false
	bs_defensive_mgr.def_ind_latch.reset_time = 0
	bs_defensive_mgr.def_ind_latch.triggered_state = nil
	bs_defensive_mgr.reset_game_events_state()
	bs_v120 = {}
	bs_v104 = {}
	bs_v89 = {}
end

events.round_start(bs_v384)
events.level_change(bs_v384)
events.player_death(function(arg_341_0)
	local var_341_0 = entity.get_local_player()

	if not var_341_0 then
		return
	end

	if entity.get(arg_341_0.userid, true) == var_341_0 then
		bs_v384()
	end
end)

function bs_v567(arg_342_0, arg_342_1, arg_342_2)
	arg_342_0 = arg_342_0 or "?"

	local var_342_0 = arg_342_0 .. (arg_342_1 and ":hit" or ":miss")
	local var_342_1 = globals.realtime

	if var_342_0 == bs_v577 and var_342_1 - bs_v585 < 0.1 then
		return
	end

	bs_v577 = var_342_0
	bs_v585 = var_342_1

	local var_342_2 = bs_get_state.get and bs_get_state.get(bs_legit_aa.is_working)
	local var_342_3 = false
	local var_342_4 = false
	local var_342_5 = false
	local var_342_6 = false

	if var_342_2 then
		local var_342_7 = bs_menu.antiaim.angles.builder and bs_menu.antiaim.angles.builder[var_342_2]

		var_342_3 = var_342_7 and var_342_7.anti_bruteforce and var_342_7.anti_bruteforce:get() or false
		var_342_5 = var_342_7 and var_342_7.abf_notify ~= nil and var_342_7.abf_notify:get() or false

		local var_342_8 = bs_menu.antiaim.defensive
		local var_342_9 = var_342_8 and var_342_8.settings and var_342_8.settings[var_342_2]

		var_342_4 = var_342_9 and var_342_9.def_abf and var_342_9.def_abf:get() or false
		var_342_6 = var_342_9 and var_342_9.def_abf_notify and var_342_9.def_abf_notify:get() or false
	end

	if arg_342_2 and not var_342_6 then
		return
	end

	if not arg_342_2 and not var_342_5 then
		return
	end

	local var_342_10
	local var_342_11

	var_342_11 = var_342_3 and var_342_4 and "anti-bruteforce" or arg_342_2 and "def abf" or "abf"

	local var_342_12 = bs_menu.info and bs_menu.info.notify
	local var_342_13

	if arg_342_1 then
		var_342_13 = var_342_12 and var_342_12.col_abf_hit and var_342_12.col_abf_hit:get() or color(0, 255, 0, 255)
	else
		var_342_13 = var_342_12 and var_342_12.col_abf_miss and var_342_12.col_abf_miss:get() or color(255, 0, 0, 255)
	end

	local var_342_14 = arg_342_1 and "hit" or "miss"
	local var_342_15, var_342_16 = pcall(function()
		return bs_menu.info.notify.log_mode:get()
	end)

	bs_notify.new({
		"anti-bruteforce triggered by ",
		string.lower(arg_342_0),
		" due to ",
		var_342_14,
		" impact - angle shifted"
	}, var_342_13)
end

bs_anti_brute = {}
bs_v596 = {}

for iter_0_35, iter_0_36 in ipairs(bs_states.states) do
	bs_v596[iter_0_36] = {
		rnd_shots = 0,
		phase_current = 0,
		reset_dur = 3,
		reset_time = 0,
		last_tick = 0,
		is_working = false,
		offset = 0,
		saved_inv = false,
		trick_tick = 0,
		trigger_time = 0,
		rnd_amount = 0
	}
end

bs_v607 = {}

for iter_0_37, iter_0_38 in ipairs(bs_states.states) do
	bs_v607[iter_0_38] = false
end

bs_v617 = {
	rnd_shots = 0,
	phase_current = 0,
	reset_time = 0,
	is_working = false,
	offset = 0,
	saved_inv = false,
	trick_tick = 0,
	trigger_time = 0,
	rnd_amount = 0
}
bs_v634 = {}
bs_v647 = {}
bs_v655 = {}

function bs_v660(arg_344_0)
	while arg_344_0 > 180 do
		arg_344_0 = arg_344_0 - 360
	end

	while arg_344_0 < -180 do
		arg_344_0 = arg_344_0 + 360
	end

	return arg_344_0
end

function bs_v672(arg_345_0, arg_345_1, arg_345_2)
	local var_345_0 = arg_345_2 * math.pi / 180

	return vector(arg_345_0.x + math.cos(var_345_0) * arg_345_1, arg_345_0.y + math.sin(var_345_0) * arg_345_1, arg_345_0.z)
end

local function bs_v591(arg_352_0, arg_352_1, arg_352_2)
	local var_352_0 = bs_get_state.get(bs_legit_aa.is_working)

	if not var_352_0 then
		return
	end

	local var_352_1 = bs_v596[var_352_0]

	if not var_352_1 then
		return
	end

	local var_352_2 = bs_menu.antiaim.angles.builder[var_352_0]

	if not var_352_2 or not var_352_2.anti_bruteforce:get() then
		return
	end

	-- On-shot trigger: fire ABF when we shoot, regardless of miss/hit mode
	if not arg_352_2 then
		local var_352_3 = var_352_2.abf_trigger and var_352_2.abf_trigger:get() or "miss"

		if arg_352_1 and var_352_3 == "miss" then
			return
		end

		if not arg_352_1 and var_352_3 == "hit" then
			return
		end
	end

	local var_352_4 = var_352_2.abf_reset_timer and var_352_2.abf_reset_timer:get() or 3

	if var_352_1.reset_time > 0 and globals.realtime >= var_352_1.reset_time then
		bs_v607[var_352_0] = false
		var_352_1.reset_time = 0
		bs_v617.is_working = false
		bs_v617.reset_time = 0
		bs_v617.triggered_state = nil
	end

	if var_352_1.last_tick == globals.tickcount then
		return
	end

	var_352_1.last_tick = globals.tickcount
	var_352_1.reset_dur = var_352_4
	var_352_1.reset_time = globals.realtime + var_352_4
	var_352_1.trigger_time = globals.realtime
	var_352_1.trick_tick = 0
	var_352_1.saved_inv = rage.antiaim:inverter()

	if (var_352_2.abf_phase_n or 0) > 0 then
		var_352_1.phase_current = var_352_1.phase_current + 1
		var_352_1.is_working = true
	end

	bs_v617.is_working = var_352_1.is_working
	bs_v617.offset = var_352_1.offset
	bs_v617.phase_current = var_352_1.phase_current
	bs_v617.rnd_shots = var_352_1.rnd_shots
	bs_v617.rnd_amount = var_352_1.rnd_amount
	bs_v617.reset_time = var_352_1.reset_time
	bs_v617.triggered_state = var_352_0
	bs_v617.mode = "custom"
	bs_v617.trigger_time = var_352_1.trigger_time
	bs_v617.trick_tick = 0
	bs_v617.saved_inv = var_352_1.saved_inv
	bs_anti_brute.ind_latch.is_working = true
	bs_anti_brute.ind_latch.reset_time = var_352_1.reset_time
	bs_anti_brute.ind_latch.reset_dur = var_352_1.reset_dur
	bs_anti_brute.ind_latch.triggered_state = var_352_0
	if bs_v169 then
		bs_v169.anim = 1
		bs_v169.value = 1
	end

	if var_352_2.abf_notify ~= nil and var_352_2.abf_notify:get() and not bs_v607[var_352_0] then
		bs_v607[var_352_0] = true

		bs_v567(arg_352_0.name, arg_352_1, false)
	end
end

events.player_hurt(function(arg_346_0)
	local var_346_0 = entity.get_local_player()

	if not var_346_0 or not var_346_0:is_alive() then
		return
	end

	local var_346_1 = entity.get(arg_346_0.userid, true)
	local var_346_2 = entity.get(arg_346_0.attacker, true)

	if not var_346_2 or not var_346_2:is_enemy() or var_346_1 ~= var_346_0 then
		return
	end

	local var_346_3 = {
		"knife",
		"hegrenade",
		"inferno",
		"flashbang",
		"decoy",
		"smokegrenade",
		"taser"
	}

	for iter_346_0, iter_346_1 in ipairs(var_346_3) do
		if arg_346_0.weapon == iter_346_1 then
			return
		end
	end

	local var_346_4 = var_346_2:get_index()
	local var_346_5, var_346_6 = pcall(function()
		return var_346_2:get_name()
	end)
	local var_346_7 = {
		name = var_346_5 and var_346_6 or "?",
		time = globals.curtime
	}

	bs_v591(var_346_7, true)

	bs_v655[var_346_4] = var_346_7.time
	bs_v647[var_346_4] = nil
	bs_v634[var_346_4] = nil
end)
events.bullet_impact(function(arg_348_0)
	local var_348_0 = entity.get_local_player()

	if not var_348_0 or not var_348_0:is_alive() then
		return
	end

	local var_348_1 = entity.get(arg_348_0.userid, true)

	if not var_348_1 or not var_348_1:is_enemy() or not var_348_1:is_alive() or var_348_1:is_dormant() then
		return
	end

	local var_348_2 = var_348_1:get_index()
	local var_348_3 = var_348_0.m_vecOrigin
	local var_348_4 = var_348_1.m_vecOrigin
	local var_348_5 = math.atan(var_348_3.y - var_348_4.y, var_348_3.x - var_348_4.x) * 180 / math.pi
	local var_348_6 = var_348_0:get_origin() + var_348_0.m_vecViewOffset
	local var_348_7 = var_348_1:get_origin() + var_348_1.m_vecViewOffset
	local var_348_8 = vector(arg_348_0.x, arg_348_0.y, arg_348_0.z)
	local var_348_9 = bs_v672(var_348_6, 16, bs_v660(var_348_5 - 45 + 180))
	local var_348_10 = bs_v672(var_348_6, 16, bs_v660(var_348_5 + 45 + 180))
	local var_348_11 = var_348_9:closest_ray_point(var_348_7, var_348_8)
	local var_348_12 = var_348_10:closest_ray_point(var_348_7, var_348_8)
	local var_348_13 = var_348_11:dist(var_348_9)
	local var_348_14 = var_348_12:dist(var_348_10)

	if var_348_13 < 70 or var_348_14 < 70 then
		local var_348_15, var_348_16 = pcall(function()
			return var_348_1:get_name()
		end)
		local var_348_17 = {
			name = var_348_15 and var_348_16 or "?",
			time = globals.curtime
		}

		bs_v591(var_348_17, false)

		bs_v655[var_348_2] = var_348_17.time
		bs_v634[var_348_2] = nil
	end
end)

bs_anti_brute.abf_state = bs_v596
	bs_anti_brute.ind_latch = {
		is_working = false,
		reset_dur = 3,
		reset_time = 0
	}
	bs_anti_brute.on_shot_last_attack = false

-- #############################################################################
-- #  [SEC-14] ANTI-BRUTE
-- #############################################################################
function bs_anti_brute.reset(arg_353_0)
	local var_353_0 = arg_353_0 and {
		arg_353_0
	} or bs_states.states

	for iter_353_0, iter_353_1 in ipairs(var_353_0) do
		local var_353_1 = bs_v596[iter_353_1]

		if var_353_1 then
			var_353_1.last_tick = 0
			var_353_1.reset_time = 0
			var_353_1.is_working = false
			var_353_1.offset = 0
			var_353_1.phase_current = 0
			var_353_1.rnd_shots = 0
			var_353_1.rnd_amount = 0
			var_353_1.trigger_time = 0
			var_353_1.trick_tick = 0
			var_353_1.saved_inv = false
		end

		bs_v607[iter_353_1] = false
	end

	if not arg_353_0 or bs_v617.triggered_state == arg_353_0 then
		bs_v617.is_working = false
		bs_v617.offset = 0
		bs_v617.phase_current = 0
		bs_v617.rnd_shots = 0
		bs_v617.rnd_amount = 0
		bs_v617.reset_time = 0
		bs_v617.triggered_state = nil
		bs_v617.mode = nil
		bs_v617.trigger_time = 0
		bs_v617.trick_tick = 0
		bs_v617.saved_inv = false

		if not arg_353_0 then
			bs_anti_brute.ind_latch.is_working = false
			bs_anti_brute.ind_latch.reset_time = 0
		end
	end
end

function bs_anti_brute.update(arg_354_0, arg_354_1, arg_354_2, arg_354_3)
	if not arg_354_3 or not arg_354_3.anti_bruteforce:get() then
		local var_354_0 = bs_v596[arg_354_2]

		if var_354_0 and var_354_0.is_working then
			bs_anti_brute.reset(arg_354_2)
		end

		local var_354_1 = bs_anti_brute.ind_latch

		if var_354_1.is_working then
			local var_354_2 = var_354_1.triggered_state
			local var_354_3 = bs_menu.antiaim.angles.builder and var_354_2 and bs_menu.antiaim.angles.builder[var_354_2]

			if not (var_354_3 and var_354_3.anti_bruteforce and var_354_3.anti_bruteforce:get() or false) then
				var_354_1.is_working = false
				var_354_1.reset_time = 0
				var_354_1.triggered_state = nil
			end
		end

		return
	end

	local var_354_4 = bs_v596[arg_354_2]

	if not var_354_4 then
		return
	end

	if var_354_4.reset_time > 0 and globals.realtime >= var_354_4.reset_time then
		bs_anti_brute.reset(arg_354_2)
	end

	if bs_v617.reset_time > 0 and globals.realtime >= bs_v617.reset_time then
		bs_v617.is_working = false
		bs_v617.reset_time = 0
		bs_v617.triggered_state = nil
		bs_v617.trigger_time = 0
		bs_v617.trick_tick = 0
		bs_v617.saved_inv = false
	end

	local var_354_5 = var_354_4.is_working and var_354_4 or bs_v617.is_working and bs_v617 or nil

	if not var_354_5 then
		return
	end

	if arg_354_0.choked_commands == 0 then
		var_354_5.trick_tick = var_354_5.trick_tick + 1
	end

	local var_354_6 = var_354_5 == var_354_4 and arg_354_3 or bs_menu.antiaim.angles.builder[bs_v617.triggered_state] or arg_354_3
	local var_354_7 = var_354_6.abf_phase_n or 0
	local var_354_8 = var_354_5.phase_current

	if var_354_7 > 0 and var_354_8 > 0 then
		local var_354_9 = (var_354_8 - 1) % var_354_7 + 1
		local var_354_10 = var_354_6.abf_phases and var_354_6.abf_phases[var_354_9]

		if var_354_10 then
			local var_354_11 = var_354_10.rand_min:get()
			local var_354_12 = var_354_10.rand_max:get()

			if var_354_12 < var_354_11 then
				var_354_11, var_354_12 = var_354_12, var_354_11
			end

			local var_354_13 = math.random(var_354_11, var_354_12)

			local var_354_14, var_354_15
			if var_354_13 >= 0 then
				var_354_15 = math.ceil(var_354_13 / 2)
				var_354_14 = var_354_13 - var_354_15
			else
				var_354_14 = math.floor(var_354_13 / 2)
				var_354_15 = var_354_13 - var_354_14
			end
			arg_354_1._lr_left = (arg_354_1._lr_left or 0) + var_354_14
			arg_354_1._lr_right = (arg_354_1._lr_right or 0) + var_354_15
		end
	end
end

events.round_start(function()
	bs_anti_brute.reset()

	bs_anti_brute.ind_latch.triggered_state = nil
	bs_anti_brute.on_shot_last_attack = false
	bs_v617.is_working = false
	bs_v617.offset = 0
	bs_v617.phase_current = 0
	bs_v617.rnd_shots = 0
	bs_v617.rnd_amount = 0
	bs_v617.reset_time = 0
	bs_v617.triggered_state = nil
	bs_v617.mode = nil
	bs_v617.trigger_time = 0
	bs_v617.trick_tick = 0
	bs_v617.saved_inv = false
	bs_v647 = {}
	bs_v634 = {}
	bs_v655 = {}
end)
events.player_disconnect(function(arg_356_0)
	local var_356_0 = arg_356_0.userid

	bs_v647[var_356_0] = nil
	bs_v634[var_356_0] = nil
	bs_v655[var_356_0] = nil
end)
events.player_death(function(arg_357_0)
	local var_357_0 = entity.get_local_player()

	if not var_357_0 then
		return
	end

	if entity.get(arg_357_0.userid, true) == var_357_0 then
		bs_anti_brute.reset()

		bs_anti_brute.ind_latch.triggered_state = nil
	end
end)

bs_aa_state_factory = {}
bs_aa_state = {
	reset = function(arg_358_0)
		for iter_358_0, iter_358_1 in pairs(bs_config.antiaim.angles) do
			iter_358_1:override()
		end
	end,
	define = function(arg_359_0)
		arg_359_0.pitch = nil
		arg_359_0.yaw = nil
		arg_359_0.yaw_offset = nil
		arg_359_0.yaw_base = nil
		arg_359_0.yaw_modifier = nil
		arg_359_0.modifier_offset = nil
		arg_359_0.left_limit = nil
		arg_359_0.right_limit = nil
		arg_359_0.body_yaw = nil
		arg_359_0.body_yaw_options = nil
		arg_359_0.disable_yaw_modifiers = nil
		arg_359_0.body_freestanding = nil
		arg_359_0.freestanding = nil
		arg_359_0.freestand_peek = nil
		arg_359_0.lag_options = nil
		arg_359_0.hs_options = nil
		arg_359_0.avoid_backstab = nil
		arg_359_0.ignore_inverter = false
		arg_359_0.inverter = nil
		arg_359_0.way = nil
		arg_359_0._yaw_mode = nil
		arg_359_0._async_yaw_active = nil
	end,
	run = function(arg_360_0)
		if arg_360_0.yaw_modifier == "Custom Ways" and arg_360_0.way then
			local var_360_0 = #arg_360_0.way

			if var_360_0 > 0 then
				local var_360_1 = globals.tickcount % var_360_0 + 1

				arg_360_0.yaw_offset = (arg_360_0.yaw_offset or 0) + (arg_360_0.way[var_360_1] or 0)
			end

			arg_360_0.yaw_modifier = "Disabled"
			arg_360_0.modifier_offset = 0
		end

		bs_config.antiaim.angles.pitch:override(arg_360_0.pitch or "Disabled")
		bs_config.antiaim.angles.yaw:override(arg_360_0.yaw or "disabled")
		bs_config.antiaim.angles.yaw_add:override(arg_360_0.yaw_offset or 0)

		local var_360_2 = {
			["Local view"] = "Local View",
			["Local View"] = "Local View",
			["At Target"] = "At Target",
			["At target"] = "At Target",
			["at target"] = "At Target",
			["local view"] = "Local View"
		}

		bs_config.antiaim.angles.yaw_base:override(var_360_2[arg_360_0.yaw_base] or arg_360_0.yaw_base or "Local View")
		bs_config.antiaim.angles.yaw_modifier:override(arg_360_0.yaw_modifier or "Disabled")
		bs_config.antiaim.angles.modifier_offset:override(arg_360_0.modifier_offset or 0)
		bs_config.antiaim.angles.body_yaw:override(arg_360_0.body_yaw == true)

		if arg_360_0.body_yaw == true then
			local var_360_3 = arg_360_0.inverter == nil and rage.antiaim:inverter() or (arg_360_0.inverter == true)

			bs_config.antiaim.angles.inverter:override(var_360_3)
			bs_config.antiaim.angles.left_limit:override(arg_360_0.left_limit or 0)
			bs_config.antiaim.angles.right_limit:override(arg_360_0.right_limit or 0)
		else
			bs_config.antiaim.angles.left_limit:override(arg_360_0.left_limit or 0)
			bs_config.antiaim.angles.right_limit:override(arg_360_0.right_limit or 0)
		end

		bs_config.antiaim.angles.options:override(arg_360_0.body_yaw_options or {})
		bs_config.antiaim.angles.disable_yaw_modifiers:override(arg_360_0.disable_yaw_modifiers == true)
		bs_config.antiaim.angles.body_freestanding:override(arg_360_0.body_freestanding == true)
		bs_config.antiaim.angles.freestanding:override(arg_360_0.freestanding == true)

		local var_360_4 = {
			["peek real"] = "Peek Real",
			off = "Off",
			["peek fake"] = "Peek Fake",
			["Peek Real"] = "Peek Real",
			["Peek Fake"] = "Peek Fake",
			Off = "Off"
		}

		bs_config.antiaim.angles.freestand_peek:override(var_360_4[arg_360_0.freestand_peek] or arg_360_0.freestand_peek or "Off")

		local var_360_5 = {
			["On Peek"] = "On Peek",
			["Always on"] = "Always On",
			["Always On"] = "Always On"
		}

		bs_config.rage.main.double_tap_lag_options:override(var_360_5[arg_360_0.lag_options] or arg_360_0.lag_options or "On Peek")

		local var_360_6 = {
			["favor fire rate"] = "Favor Fire Rate",
			["break lc"] = "Break LC",
			["favor fake lag"] = "Favor Fake Lag"
		}

		bs_config.rage.main.hide_shots_options:override(var_360_6[arg_360_0.hs_options] or arg_360_0.hs_options or "Favor Fire Rate")
		bs_config.antiaim.angles.avoid_backstab:override(arg_360_0.avoid_backstab or false)
	end
}

bs_aa_state:reset()

function bs_aa_state_factory.create_antiaim()
	return setmetatable({}, {
		__index = bs_aa_state
	})
end

bs_def_snap = {}
bs_v613 = {
	running = true,
	air = true,
	["air crouching"] = true,
	slowing = true,
	sneaking = true,
	crouching = true,
	standing = true
}
bs_def_snap.active = false
bs_v625 = 0
bs_v642 = false
bs_def_snap_tick = nil

-- #############################################################################
-- #  [SEC-15] DEFENSIVE SNAPSHOT
-- #############################################################################
function bs_def_snap.think(arg_362_0)
	if not bs_v613[arg_362_0] then
		return false
	end

	local var_362_0 = entity.get_local_player()

	if not var_362_0 or not var_362_0:is_alive() then
		return false
	end

	local var_362_1 = var_362_0:get_player_weapon()

	if not var_362_1 or var_362_1:get_weapon_index() == 64 then
		return false
	end

	local var_362_2 = bs_config.rage.main.double_tap
	local var_362_3 = bs_config.rage.main.hide_shots

	if (not var_362_2 or not var_362_2:get()) and (not var_362_3 or not var_362_3:get()) and not bs_auto_hide_shots.is_active then
		return false
	end

	if rage.exploit:get() ~= 1 then
		return false
	end

	local var_362_4 = bs_menu.antiaim.defensive.settings[arg_362_0]

	if not var_362_4 or not var_362_4.fe or not var_362_4.fe:get() then
		return false
	end

	local var_362_5 = var_362_4.fe_alt and var_362_4.fe_alt:get() or false
	local var_362_6 = var_362_4.fe_peek and var_362_4.fe_peek:get() or false
	local var_362_7 = var_362_4.fe_snap_delay and var_362_4.fe_snap_delay:get() or 0

	return true, var_362_5, var_362_6, var_362_7
end

function bs_def_snap.apply(arg_363_0, arg_363_1, arg_363_2, arg_363_3, arg_363_4)
	bs_def_snap.active = true
	arg_363_1.pitch = "Down"
	arg_363_1.yaw = "backward"
	arg_363_1.yaw_base = "At Target"
	arg_363_1.yaw_offset = 12
	arg_363_1.yaw_modifier = "Disabled"
	arg_363_1.modifier_offset = 0
	arg_363_1.body_yaw = true
	arg_363_1.body_yaw_options = arg_363_3 and {
		"Avoid Overlap"
	} or {}
	arg_363_1.left_limit = 60
	arg_363_1.right_limit = 60
	arg_363_1.freestanding = false
	arg_363_1.body_freestanding = false
	arg_363_1.freestand_peek = arg_363_3 and "peek fake" or "off"

	bs_config.antiaim.angles.hidden:override(true)
	bs_config.antiaim.angles.inverter:override(false)
	arg_363_1.inverter = false

	local var_363_0 = arg_363_0.choked_commands == 0

	if bs_def_snap_tick == nil then
		bs_def_snap_tick = globals.tickcount
		bs_v625 = 0
		bs_v642 = false
	end

	if arg_363_4 == 0 then
		if var_363_0 then
			bs_v642 = not bs_v642
		end
	elseif var_363_0 then
		if arg_363_4 <= bs_v625 then
			bs_v642 = not bs_v642
			bs_v625 = 0
		else
			bs_v625 = bs_v625 + 1
		end
	end

	local var_363_1 = rage.antiaim:inverter()
	local var_363_2 = bs_v642 and not var_363_1 or not bs_v642 and var_363_1

	rage.antiaim:override_hidden_yaw_offset(var_363_2 and 90 or -90)
	rage.antiaim:override_hidden_pitch(arg_363_2 and utils.random_float(-5, 5) or 89)
end

function bs_def_snap.reset_snap()
	bs_def_snap_tick = nil
	bs_v625 = 0
	bs_v642 = false
end

bs_shot_record = {
	yaw = 0,
	oz = 0,
	oy = 0,
	ox = 0,
	fired = false
}
bs_v624 = false
bs_v641 = 0

function bs_v652(arg_365_0, arg_365_1, arg_365_2)
	local var_365_0 = math.max(1, arg_365_1 or 2)

	if arg_365_0.choked_commands == 0 then
		bs_v641 = bs_v641 + 1
	end

	local var_365_1 = false

	if var_365_0 <= bs_v641 then
		bs_v641 = 0
		bs_v624 = not bs_v624
		var_365_1 = true
	end

	bs_config.antiaim.angles.inverter:override(bs_v624 == true)

	return var_365_1
end

bs_aa_updater = {}
bs_aa_state_obj = bs_aa_state_factory.create_antiaim()

-- #############################################################################
-- #  [SEC-16] ANTI-AIM UPDATER (YAW / BODY YAW / MODIFIER MATH)
-- #############################################################################
function bs_aa_updater.get_exploit_values(arg_366_0, arg_366_1)
	return ({
		-arg_366_0,
		-arg_366_0 / 2,
		-arg_366_0 / 3,
		arg_366_0 / 3,
		arg_366_0 / 2,
		arg_366_0
	})[arg_366_1 or 1]
end

function bs_aa_updater.get_preset(arg_367_0)
	return bs_menu.antiaim.angles.builder[arg_367_0]
end

bs_v678 = 1
bs_v689 = 0
bs_v700 = 0
bs_v710 = false
bs_v721 = false
bs_v734 = false
bs_v746 = {}
bs_v756 = {}
bs_v766 = {}
bs_v13 = {}
bs_v28 = {}
bs_v40 = {}
bs_v55 = {}
bs_v58 = {}
bs_v73 = {}
bs_v88 = {}
bs_v103 = {}
bs_v119 = {}
bs_v136 = {}
bs_v154 = {}
bs_v179 = {}
bs_v201 = {}
bs_v220 = {}
bs_v222 = {}
bs_v223 = {}
bs_v240 = {}
bs_v259 = {}
bs_v274 = {}
bs_v288 = {}
bs_v302 = {}
bs_v315 = {}
bs_v_random_body_yaw_limit = {}
bs_v330 = 0
bs_v343 = false

events.createmove_run(function()
	local var_368_0 = entity.get_local_player()
	if not var_368_0 then return end
	local var_368_1, var_368_2 = pcall(function() return var_368_0.m_nTickBase end)
	if not var_368_1 or not var_368_2 then return end
	local var_368_3 = math.abs(var_368_2 - bs_v330)
	bs_v330 = math.max(var_368_2, bs_v330 or 0)
	if var_368_3 % 3 == 1 then
		bs_v343 = not bs_v343
	end
end)

function bs_async_flip(arg_368_0)
	if bs_v746[arg_368_0] ~= nil then
		return
	end

	bs_v746[arg_368_0] = 0
	bs_v756[arg_368_0] = false
	bs_v766[arg_368_0] = 0
	bs_v13[arg_368_0] = 0
	bs_v28[arg_368_0] = 0
	bs_v40[arg_368_0] = 0
	bs_v55[arg_368_0] = 0
	bs_v58[arg_368_0] = 0
	bs_v73[arg_368_0] = 1
	bs_v88[arg_368_0] = 1
	bs_v103[arg_368_0] = 0
	bs_v119[arg_368_0] = 0
	bs_v136[arg_368_0] = 0
	bs_v154[arg_368_0] = 0
	bs_v179[arg_368_0] = 0
	bs_v201[arg_368_0] = 0
	bs_v220[arg_368_0] = 0
	bs_v240[arg_368_0] = 0
	bs_v259[arg_368_0] = false
	bs_v274[arg_368_0] = 0
	bs_v288[arg_368_0] = 1
	bs_v302[arg_368_0] = false
	bs_v315[arg_368_0] = false
end

bs_v351 = {
	3,
	2,
	4,
	2,
	3,
	2
}
bs_v354 = 1
bs_v373 = 0
bs_v383 = false
bs_v391 = 0
bs_v400 = false

function bs_v408(arg_369_0)
	if arg_369_0.choked_commands == 0 then
		if bs_v400 then
			bs_v400 = false
		end

		bs_v391 = 0
		bs_v373 = bs_v373 + 1

		if bs_v373 >= bs_v351[bs_v354] then
			bs_v373 = 0
			bs_v354 = bs_v354 % #bs_v351 + 1
			bs_v383 = not bs_v383
		end

		bs_config.antiaim.angles.inverter:override(bs_v383 == true)
	else
		bs_v391 = bs_v391 + 1

		if bs_v391 == 3 and not bs_v400 then
			bs_v400 = true

			bs_config.antiaim.angles.inverter:override(not bs_v383)
		end
	end
end

bs_v416 = 0
bs_v423 = 0
bs_v428 = 0
bs_v432 = 0
bs_v436 = 0
bs_v440 = 0
bs_v444 = 1
bs_v448 = 8
bs_v452 = 58
bs_v455 = 0

function bs_hit_result()
	local var_370_0 = entity.get_local_player()

	if not var_370_0 or not var_370_0:is_alive() then
		return 1
	end

	local var_370_1 = var_370_0:get_origin()
	local var_370_2 = render.camera_angles().y
	local var_370_3 = 0
	local var_370_4 = 0

	bs_iter_players(true, false, function(arg_371_0)
		if arg_371_0:is_dormant() or not arg_371_0:is_alive() then
			return
		end

		local var_371_0 = arg_371_0:get_origin()
		local var_371_1 = var_370_1:dist(var_371_0)

		if var_371_1 < 1 then
			return
		end

		local var_371_2 = 1 / (var_371_1 * var_371_1)

		var_370_3 = var_370_3 + var_371_0.x * var_371_2
		var_370_4 = var_370_4 + var_371_0.y * var_371_2
	end)

	if var_370_3 == 0 and var_370_4 == 0 then
		return 1
	end

	local var_370_5 = math.deg(math.atan2(var_370_4 - var_370_1.y, var_370_3 - var_370_1.x))

	return math.fmod(var_370_5 - var_370_2 + 540, 360) - 180 >= 0 and -1 or 1
end

function bs_jitter_math(arg_372_0, arg_372_1, arg_372_2, arg_372_3, arg_372_4, arg_372_5)
	local var_372_0 = math.max(1, arg_372_1) * 2
	local var_372_1 = arg_372_0 % var_372_0 / var_372_0
	local var_372_2 = (arg_372_4 or 0) * math.pi / 180
	local var_372_3 = arg_372_5 and arg_372_5 / 100 or 0
	local var_372_4 = 0

	if arg_372_3 == "sine" then
		var_372_4 = math.sin(var_372_1 * math.pi * 2 + var_372_2) * arg_372_2
	elseif arg_372_3 == "triangle" then
		local var_372_5 = var_372_1 * 2

		if var_372_5 > 1 then
			var_372_5 = 2 - var_372_5
		end

		var_372_4 = (var_372_5 * 2 - 1) * arg_372_2
	elseif arg_372_3 == "bounce" then
		local var_372_6 = var_372_1 * 2

		if var_372_6 > 1 then
			var_372_6 = 2 - var_372_6
		end

		var_372_4 = (var_372_6 * 2 - 1) * arg_372_2
	elseif arg_372_3 == "step" then
		var_372_4 = var_372_1 < 0.5 and arg_372_2 or -arg_372_2
	elseif arg_372_3 == "noise" then
		var_372_4 = math.random(-math.floor(arg_372_2), math.floor(arg_372_2))
	end

	if var_372_3 ~= 0 then
		var_372_4 = var_372_4 * (1 + (var_372_4 > 0 and var_372_3 or -var_372_3))
	end

	return var_372_4
end

function bs_flip_jitter_math(arg_373_0, arg_373_1, arg_373_2, arg_373_3)
	if not arg_373_0.flip_jitter or not arg_373_0.flip_jitter:get() then
		return arg_373_1
	end

	local var_373_0 = arg_373_0.flip_jitter_mode:get()
	local var_373_1 = arg_373_0.flip_jitter_amt:get()

	if var_373_0 == "additive" then
		return arg_373_1 + math.random(0, var_373_1)
	elseif var_373_0 == "subtractive" then
		return arg_373_1 - math.random(0, var_373_1)
	elseif var_373_0 == "alternating" then
		local var_373_2 = arg_373_0.flip_jitter_rate:get()

		bs_v766[arg_373_3] = (bs_v766[arg_373_3] or 0) + 1

		if var_373_2 <= bs_v766[arg_373_3] then
			bs_v766[arg_373_3] = 0
			bs_v756[arg_373_3] = not bs_v756[arg_373_3]
		end

		return arg_373_1 + (bs_v756[arg_373_3] and var_373_1 or -var_373_1)
	elseif var_373_0 == "noise" then
		return arg_373_1 + math.random(-var_373_1, var_373_1)
	elseif var_373_0 == "spike" then
		local var_373_3 = arg_373_0.flip_jitter_spike_dur and arg_373_0.flip_jitter_spike_dur:get() or 1

		if arg_373_2 then
			bs_v13[arg_373_3] = var_373_3
		end

		if bs_v13[arg_373_3] > 0 then
			bs_v13[arg_373_3] = bs_v13[arg_373_3] - 1

			return arg_373_1 + (bs_v710 and var_373_1 or -var_373_1)
		end
	end

	return arg_373_1
end

function bs_aa_updater.update_yaw(arg_374_0, arg_374_1, arg_374_2, arg_374_3)
	arg_374_1.pitch = "Down"
	arg_374_1.yaw = "backward"

	local var_374_0 = false
	local var_374_18 = nil
	arg_374_1._at_target_offset = 0

	if arg_374_2.yaw_base and arg_374_2.yaw_base:get() == "at target" then
		local var_374_1 = entity.get_local_player()
		local var_374_2 = var_374_1 and var_374_1:get_origin()
		local var_374_3 = math.huge
		local var_374_4 = nil
		local var_374_23 = render.camera_angles().y
		local var_374_24 = var_374_1 and (var_374_1.get_eye_position and var_374_1:get_eye_position() or var_374_2) or var_374_2

		local function var_374_19(arg_375_0)
			local var_375_1, var_375_2 = pcall(function()
				return arg_375_0 and arg_375_0:is_alive() and not arg_375_0:is_dormant()
			end)

			return var_375_1 and var_375_2
		end

		local function var_374_25(arg_375_0)
			if not var_374_24 or not var_374_19(arg_375_0) then
				return math.huge
			end

			local var_375_3, var_375_4 = pcall(function()
				local var_375_5 = arg_375_0.get_eye_position and arg_375_0:get_eye_position() or arg_375_0:get_origin()
				local var_375_6 = var_374_24:to(var_375_5):angles().y

				return math.abs(math.fmod(var_375_6 - var_374_23 + 540, 360) - 180)
			end)

			if var_375_3 and type(var_375_4) == "number" then
				return var_375_4
			end

			return math.huge
		end

		local function var_374_20(arg_375_0)
			if not var_374_19(arg_375_0) then
				return
			end

			local var_375_1 = var_374_25(arg_375_0)
			local var_375_2 = var_374_2 and var_374_2:dist2d(arg_375_0:get_origin()) or math.huge
			local var_375_3 = var_375_1 * 100000 + var_375_2

			if var_375_3 < var_374_3 then
				var_374_3 = var_375_3
				var_374_4 = arg_375_0
			end
		end

		-- Priority: engine crosshair threat, then visible enemies nearest crosshair, then any live enemy nearest crosshair.
		local var_374_5, var_374_6 = pcall(function()
			return entity.get_threat(true)
		end)

		if var_374_5 and var_374_6 and var_374_19(var_374_6) then
			var_374_4 = var_374_6
		end

		if not var_374_4 then
			bs_iter_players(true, false, function(arg_375_0)
				if not var_374_19(arg_375_0) then
					return
				end

				local var_375_0 = arg_375_0:get_bbox()

				if not var_375_0 or var_375_0.alpha < 0.05 then
					return
				end

				var_374_20(arg_375_0)
			end)
		end

		if not var_374_4 then
			bs_iter_players(true, false, function(arg_375_0)
				var_374_20(arg_375_0)
			end)
		end

		if var_374_4 then
			local var_374_9, var_374_10 = pcall(function()
				return var_374_4:get_origin()
			end)

			if var_374_9 and var_374_10 and var_374_2 then
				local var_374_11, var_374_12 = pcall(function()
					local var_374_13 = var_374_10 - var_374_2
					local var_374_14 = math.deg(math.atan2(var_374_13.y, var_374_13.x)) - render.camera_angles().y

					return math.fmod(var_374_14 + 540, 360) - 180
				end)

				if var_374_11 and var_374_12 then
					var_374_0 = true
					var_374_18 = var_374_12
				end
			end
		end
	end

	arg_374_1._at_target_offset = var_374_18 or 0

	if arg_374_2.yaw_base and arg_374_2.yaw_base:get() == "at target" then
		arg_374_1.yaw_base = "At Target"
	else
		arg_374_1.yaw_base = "Local View"
	end

	local var_374_4 = arg_374_2.yaw_mode and tostring(arg_374_2.yaw_mode:get()):lower() or "real angle"
	arg_374_1._yaw_mode = var_374_4

	if var_374_4 == "real angle" or var_374_4 == "left/right" then
		-- Async yaw is STRICTLY gated on the builder's per-state "async yaw" switch.
		-- If it is not selected in the builder for this state, async is forced OFF.
		local var_374_13 = arg_374_2.async_yaw and arg_374_2.async_yaw:get() or false
		local var_374_11 = false
		local var_374_12 = false
		local var_374_19 = false
		local var_374_async_always = false

		if var_374_13 then
			pcall(function() var_374_11 = rage.exploit:get() == 1 end)
			pcall(function() var_374_12 = bs_config.rage.main.hide_shots:get() end)
			pcall(function() var_374_19 = bs_config.antiaim.misc.fake_duck:get() end)

			-- Check async mode: "Exploit/HS" (default) or "Always"
			local var_374_async_mode = arg_374_2.async_yaw_mode and tostring(arg_374_2.async_yaw_mode:get()):lower() or "exploit/hs"
			var_374_async_always = var_374_async_mode == "always"
		end

		-- Aesthetic beta async: (async mode + DT exploit charged) OR (hide shots + not fake duck) -> async branch; else fallback
		local var_374_20 = false
		if var_374_13 then
			if var_374_async_always then
				var_374_20 = true  -- Always active when async yaw enabled
			else
				var_374_20 = var_374_11 or (var_374_12 and not var_374_19)  -- Exploit/HS mode
			end
		end
		-- Hard guarantee: async can never be active unless the builder switch is ON.
		if not var_374_13 then
			var_374_20 = false
		end

		if var_374_20 then
			arg_374_1._lr_left = arg_374_2.async_yaw_left and arg_374_2.async_yaw_left:get() or 0
			arg_374_1._lr_right = arg_374_2.async_yaw_right and arg_374_2.async_yaw_right:get() or 0
			
			-- Handle async swap mode
			local async_swap_mode = arg_374_2.async_swap_mode and tostring(arg_374_2.async_swap_mode:get()):lower() or "tickbase"
			local swap_on_send = async_swap_mode == "send tick" or async_swap_mode == "both"
			
			if arg_374_0.choked_commands == 0 then
				if swap_on_send then
					bs_v343 = not bs_v343
				end
				arg_374_1.yaw_offset = bs_v343 and arg_374_1._lr_left or arg_374_1._lr_right
				arg_374_1._async_sent_yaw = arg_374_1.yaw_offset
			else
				arg_374_1.yaw_offset = arg_374_1._async_sent_yaw ~= nil and arg_374_1._async_sent_yaw or (bs_v343 and arg_374_1._lr_left or arg_374_1._lr_right)
			end
			arg_374_1._lr_side = bs_v343
			arg_374_1.inverter = bs_v343
			arg_374_1._async_yaw_active = true
			arg_374_1.yaw_base = "At Target"
			arg_374_1.disable_yaw_modifiers = true
			arg_374_1.body_yaw_options = {}
			-- Use preset limits instead of hardcoded 58
			local ll = arg_374_2.left_limit and arg_374_2.left_limit:get() or 60
			local rl = arg_374_2.right_limit and arg_374_2.right_limit:get() or 60
			arg_374_1.left_limit = ll
			arg_374_1.right_limit = rl
			bs_v259[arg_374_3] = true
		else
			arg_374_1._lr_left = arg_374_2.yaw_left:get()
			arg_374_1._lr_right = arg_374_2.yaw_right:get()
			arg_374_1._lr_side = false
			arg_374_1.yaw_offset = arg_374_1._lr_right
			arg_374_1.inverter = nil
			arg_374_1._async_yaw_active = nil
			arg_374_1._async_sent_yaw = nil
			arg_374_1.left_limit = arg_374_2.left_limit and arg_374_2.left_limit:get() or 60
			arg_374_1.right_limit = arg_374_2.right_limit and arg_374_2.right_limit:get() or 60

			if bs_v259[arg_374_3] then
				bs_v259[arg_374_3] = false
			end
		end
	elseif var_374_4 == "gravity yaw" then
		local gy_enabled = arg_374_2.gravity_yaw_enabled and arg_374_2.gravity_yaw_enabled:get() or true
		if not gy_enabled then
			arg_374_1._lr_left = arg_374_2.yaw_left:get()
			arg_374_1._lr_right = arg_374_2.yaw_right:get()
			arg_374_1.yaw_offset = arg_374_1._lr_right
			arg_374_1.inverter = nil
		else
			arg_374_1._lr_left = arg_374_2.gravity_yaw_left and arg_374_2.gravity_yaw_left:get() or arg_374_2.yaw_left:get()
			arg_374_1._lr_right = arg_374_2.gravity_yaw_right and arg_374_2.gravity_yaw_right:get() or arg_374_2.yaw_right:get()

			local speed = arg_374_2.gravity_speed and arg_374_2.gravity_speed:get() or 1
			local direction = arg_374_2.gravity_direction and tostring(arg_374_2.gravity_direction:get()):lower() or "auto (sequence)"
			
			-- Speed control: only advance step every N non-choked ticks
			if arg_374_0.choked_commands == 0 then
				bs_v220[arg_374_3] = bs_v220[arg_374_3] or 0
				bs_v223[arg_374_3] = (bs_v223[arg_374_3] or 0) + 1
				
				if bs_v223[arg_374_3] >= speed then
					bs_v223[arg_374_3] = 0
					if direction == "invert sequence" then
						bs_v220[arg_374_3] = (bs_v220[arg_374_3] - 1) % 8
					else
						bs_v220[arg_374_3] = (bs_v220[arg_374_3] + 1) % 8
					end
				end
			end

			local var_374_14 = bs_v220[arg_374_3] == 0 and 8 or bs_v220[arg_374_3]
			local var_374_17 = false
			
			if direction == "manual: left" then
				var_374_17 = true
			elseif direction == "manual: right" then
				var_374_17 = false
			elseif direction == "invert sequence" then
				local var_374_15 = arg_374_2["gravity_step_" .. var_374_14]
				local var_374_16 = var_374_15 and tostring(var_374_15:get()):lower() or "right"
				var_374_17 = var_374_16 == "right"
			else
				-- Auto (sequence) - fallback to alternating if step not configured
				local var_374_15 = arg_374_2["gravity_step_" .. var_374_14]
				local var_374_16 = var_374_15 and tostring(var_374_15:get()):lower()
				if var_374_16 == "left" then
					var_374_17 = true
				elseif var_374_16 == "right" then
					var_374_17 = false
				else
					-- Fallback: alternate every step
					var_374_17 = var_374_14 % 2 == 0
				end
			end

			arg_374_1._lr_side = var_374_17
			arg_374_1.yaw_offset = var_374_17 and arg_374_1._lr_left or arg_374_1._lr_right
			arg_374_1.inverter = var_374_17

			-- Use body yaw limits if enabled
			if arg_374_2.gravity_use_limits and arg_374_2.gravity_use_limits:get() then
				local ll = arg_374_2.left_limit and arg_374_2.left_limit:get() or 60
				local rl = arg_374_2.right_limit and arg_374_2.right_limit:get() or 60
				arg_374_1.left_limit = ll
				arg_374_1.right_limit = rl
			end
		end
	elseif var_374_4 == "jitter" then
		if arg_374_0.choked_commands == 0 then
			bs_v746[arg_374_3] = (bs_v746[arg_374_3] or 0) + 1
		end

		local var_374_5 = bs_jitter_math(bs_v746[arg_374_3], arg_374_2.jitter_speed:get(), arg_374_2.jitter_range:get(), arg_374_2.jitter_style:get(), arg_374_2.jitter_phase:get(), arg_374_2.jitter_asymmetry:get())

		arg_374_1.yaw_offset = arg_374_2.jitter_base:get() + var_374_5
		arg_374_1.inverter = var_374_5 >= 0
	elseif var_374_4 == "chaotic" then
		local var_374_6 = arg_374_2.chaotic_range:get()
		local var_374_7 = arg_374_2.chaotic_seed_rate:get()
		local var_374_8 = arg_374_2.chaotic_smooth and arg_374_2.chaotic_smooth:get()

		if arg_374_0.choked_commands == 0 then
			bs_v40[arg_374_3] = (bs_v40[arg_374_3] or 0) + 1
		end

		if var_374_7 <= (bs_v40[arg_374_3] or 0) then
			bs_v40[arg_374_3] = 0
			bs_v28[arg_374_3] = (bs_v28[arg_374_3] or 0) + 1
			bs_v55[arg_374_3] = bs_v58[arg_374_3]

			math.randomseed(globals.tickcount + bs_v28[arg_374_3] * 137)

			bs_v58[arg_374_3] = math.random(-math.floor(var_374_6), math.floor(var_374_6))

			math.randomseed(globals.tickcount)
		end

		local var_374_9

		if var_374_8 then
			local var_374_10 = var_374_7 > 0 and bs_v40[arg_374_3] / var_374_7 or 0

			var_374_9 = bs_v55[arg_374_3] + (bs_v58[arg_374_3] - bs_v55[arg_374_3]) * var_374_10
		else
			var_374_9 = bs_v58[arg_374_3]
		end

		arg_374_1.yaw_offset = var_374_9
		arg_374_1.inverter = var_374_9 >= 0
	end

	if var_374_0 and not arg_374_1._async_yaw_active and arg_374_0.choked_commands == 0 then
		if var_374_4 == "gravity yaw" then
			-- Don't add at_target_offset on top of gravity yaw (causes widening)
			arg_374_1._at_target_offset = 0
		else
			arg_374_1.yaw_offset = (arg_374_1.yaw_offset or 0) + arg_374_1._at_target_offset
		end
	end

	if arg_374_1.inverter ~= nil then
		pcall(function()
			bs_config.antiaim.angles.inverter:override(arg_374_1.inverter == true)
		end)
	end
end

function bs_aa_updater.update_body_yaw(arg_376_0, arg_376_1, arg_376_2, arg_376_3)
	if not arg_376_2.body_yaw:get() then
		arg_376_1.body_yaw = false
		arg_376_1._lr_side = false

		local var_376_14 = arg_376_2.yaw_mode and tostring(arg_376_2.yaw_mode:get()):lower() or "real angle"

		if var_376_14 == "real angle" and not arg_376_1._async_yaw_active and arg_376_1._lr_left ~= nil and arg_376_1._lr_right ~= nil then
			arg_376_1.yaw_offset = arg_376_1._lr_right + (arg_376_0.choked_commands == 0 and (arg_376_1._at_target_offset or 0) or 0)
		end

		return
	end

	local var_376_0 = arg_376_2.body_yaw_mode and arg_376_2.body_yaw_mode:get() or "static"
	local var_376_1 = tostring(var_376_0):lower()
	local var_376_14 = arg_376_2.yaw_mode and tostring(arg_376_2.yaw_mode:get()):lower() or "real angle"
	local var_376_2 = false
	local var_376_3 = 0
	local var_376_13 = 0

	arg_376_1.body_yaw = true

	if var_376_1 == "jitter" then
		local var_376_4 = arg_376_2.body_yaw_delay_mode and arg_376_2.body_yaw_delay_mode:get() or "static"

		if var_376_4 == "static" then
			local var_376_5 = arg_376_2.body_yaw_delay and arg_376_2.body_yaw_delay:get() or 0

			if var_376_5 > 0 then
				local var_376_6 = var_376_5 + 2

				if arg_376_0.choked_commands == 0 then
					bs_v721 = var_376_6 > arg_376_0.tickcount % (var_376_6 * 2)
				end

				var_376_2 = bs_v721
			else
				var_376_2 = bs_v734
			end
		elseif var_376_4 == "random" then
			if arg_376_0.choked_commands == 0 then
				if bs_v274_toggle == nil then bs_v274_toggle = false end
				bs_v274_toggle = not bs_v274_toggle
				if bs_v274_toggle then
					bs_v274[arg_376_3] = bs_v274[arg_376_3] - 1
				end
			end

			if bs_v274[arg_376_3] <= 0 then
				local var_376_7 = arg_376_2.body_yaw_delay_random_min and arg_376_2.body_yaw_delay_random_min:get() or 2
				local var_376_8 = arg_376_2.body_yaw_delay_random_max and arg_376_2.body_yaw_delay_random_max:get() or 6

				if var_376_8 < var_376_7 then
					var_376_7, var_376_8 = var_376_8, var_376_7
				end

				bs_v274[arg_376_3] = math.random(var_376_7, var_376_8) + 2
				bs_v302[arg_376_3] = not bs_v302[arg_376_3]
			end

			if arg_376_0.choked_commands == 0 then
				bs_v721 = bs_v302[arg_376_3]
			end

			var_376_2 = bs_v721
		elseif var_376_4 == "sequence" then
			local var_376_9 = arg_376_2.body_yaw_delay_seq_count and arg_376_2.body_yaw_delay_seq_count:get() or 3

			if var_376_9 < bs_v288[arg_376_3] then
				bs_v288[arg_376_3] = 1
			end

			local var_376_10 = arg_376_2["body_yaw_delay_seq_s" .. bs_v288[arg_376_3]]
			local var_376_11 = var_376_10 and var_376_10:get() or 4

			if var_376_11 == 0 then
				if arg_376_0.choked_commands == 0 then
					bs_v302[arg_376_3] = not bs_v302[arg_376_3]

					if bs_v315[arg_376_3] then
						bs_v288[arg_376_3] = (bs_v288[arg_376_3] or 0) + 1

						if var_376_9 < bs_v288[arg_376_3] then
							bs_v288[arg_376_3] = 1
						end

						bs_v315[arg_376_3] = false
					else
						bs_v315[arg_376_3] = true
					end
				end

				bs_v274[arg_376_3] = 0
			else
				bs_v274[arg_376_3] = bs_v274[arg_376_3] - 1

				if bs_v274[arg_376_3] <= 0 then
					bs_v274[arg_376_3] = var_376_11 + 2
					bs_v302[arg_376_3] = not bs_v302[arg_376_3]

					if bs_v315[arg_376_3] then
						bs_v288[arg_376_3] = (bs_v288[arg_376_3] or 0) + 1

						if var_376_9 < bs_v288[arg_376_3] then
							bs_v288[arg_376_3] = 1
						end

						bs_v315[arg_376_3] = false
					else
						bs_v315[arg_376_3] = true
					end
				end
			end

			if arg_376_0.choked_commands == 0 then
				bs_v721 = bs_v302[arg_376_3]
			end

			var_376_2 = bs_v721
		end

		var_376_12 = arg_376_2.left_limit and arg_376_2.left_limit:get() or 60
		var_376_13 = arg_376_2.right_limit and arg_376_2.right_limit:get() or 60

		if arg_376_1._async_yaw_active then
			arg_376_1.left_limit = 60
			arg_376_1.right_limit = 60
		else
			arg_376_1.inverter = var_376_2
			arg_376_1._lr_side = var_376_2
			arg_376_1.left_limit = var_376_12
			arg_376_1.right_limit = var_376_13
		end
	-- Random mode: uses same delay modes as jitter, but randomizes limit between min and 60 on each flip
	elseif var_376_1 == "random" then
		local var_376_4 = arg_376_2.body_yaw_delay_mode and arg_376_2.body_yaw_delay_mode:get() or "static"

		if var_376_4 == "static" then
			local var_376_5 = arg_376_2.body_yaw_delay and arg_376_2.body_yaw_delay:get() or 0

			if var_376_5 > 0 then
				local var_376_6 = var_376_5 + 2

				if arg_376_0.choked_commands == 0 then
					bs_v721 = var_376_6 > arg_376_0.tickcount % (var_376_6 * 2)
				end

				var_376_2 = bs_v721
			else
				var_376_2 = bs_v734
			end
		elseif var_376_4 == "random" then
			if arg_376_0.choked_commands == 0 then
				if bs_v274_toggle == nil then bs_v274_toggle = false end
				bs_v274_toggle = not bs_v274_toggle
				if bs_v274_toggle then
					bs_v274[arg_376_3] = bs_v274[arg_376_3] - 1
				end
			end

			if bs_v274[arg_376_3] <= 0 then
				local var_376_7 = arg_376_2.body_yaw_delay_random_min and arg_376_2.body_yaw_delay_random_min:get() or 2
				local var_376_8 = arg_376_2.body_yaw_delay_random_max and arg_376_2.body_yaw_delay_random_max:get() or 6

				if var_376_8 < var_376_7 then
					var_376_7, var_376_8 = var_376_8, var_376_7
				end

				bs_v274[arg_376_3] = math.random(var_376_7, var_376_8) + 2
				bs_v302[arg_376_3] = not bs_v302[arg_376_3]
			end

			if arg_376_0.choked_commands == 0 then
				bs_v721 = bs_v302[arg_376_3]
			end

			var_376_2 = bs_v721
		elseif var_376_4 == "sequence" then
			local var_376_9 = arg_376_2.body_yaw_delay_seq_count and arg_376_2.body_yaw_delay_seq_count:get() or 3

			if var_376_9 < bs_v288[arg_376_3] then
				bs_v288[arg_376_3] = 1
			end

			local var_376_10 = arg_376_2["body_yaw_delay_seq_s" .. bs_v288[arg_376_3]]
			local var_376_11 = var_376_10 and var_376_10:get() or 4

			if var_376_11 == 0 then
				if arg_376_0.choked_commands == 0 then
					bs_v302[arg_376_3] = not bs_v302[arg_376_3]

					if bs_v315[arg_376_3] then
						bs_v288[arg_376_3] = (bs_v288[arg_376_3] or 0) + 1

						if var_376_9 < bs_v288[arg_376_3] then
							bs_v288[arg_376_3] = 1
						end

						bs_v315[arg_376_3] = false
					else
						bs_v315[arg_376_3] = true
					end
				end

				bs_v274[arg_376_3] = 0
			else
				bs_v274[arg_376_3] = bs_v274[arg_376_3] - 1

				if bs_v274[arg_376_3] <= 0 then
					bs_v274[arg_376_3] = var_376_11 + 2
					bs_v302[arg_376_3] = not bs_v302[arg_376_3]

					if bs_v315[arg_376_3] then
						bs_v288[arg_376_3] = (bs_v288[arg_376_3] or 0) + 1

						if var_376_9 < bs_v288[arg_376_3] then
							bs_v288[arg_376_3] = 1
						end

						bs_v315[arg_376_3] = false
					else
						bs_v315[arg_376_3] = true
					end
				end
			end

			if arg_376_0.choked_commands == 0 then
				bs_v721 = bs_v302[arg_376_3]
			end

			var_376_2 = bs_v721
		end

		-- On flip, pick random limit between the set limit (fake_limit_random) and 60
		if arg_376_0.choked_commands == 0 then
			local min_limit = arg_376_2.fake_limit_random and math.abs(arg_376_2.fake_limit_random:get()) or 0
			var_376_3 = math.random(min_limit, 60)
			bs_v_random_body_yaw_limit[arg_376_3] = var_376_3
		else
			var_376_3 = bs_v_random_body_yaw_limit[arg_376_3] or 0
		end

		if arg_376_1._async_yaw_active then
			arg_376_1.left_limit = 60
			arg_376_1.right_limit = 60
		else
			arg_376_1.inverter = var_376_2
			arg_376_1._lr_side = var_376_2
			arg_376_1.left_limit = var_376_3
			arg_376_1.right_limit = var_376_3
		end
	else
		var_376_2 = rage.antiaim:inverter()
		var_376_3 = arg_376_2.fake_limit_static and arg_376_2.fake_limit_static:get() or 60
		if not arg_376_1._async_yaw_active then
			arg_376_1.inverter = false
			arg_376_1._lr_side = var_376_2
			arg_376_1.left_limit = var_376_3
			arg_376_1.right_limit = var_376_3
		else
			arg_376_1.left_limit = 60
			arg_376_1.right_limit = 60
		end
	end

	if var_376_14 == "real angle" and not arg_376_1._async_yaw_active and arg_376_1._lr_left ~= nil and arg_376_1._lr_right ~= nil then
		arg_376_1.yaw_offset = (var_376_2 and arg_376_1._lr_left or arg_376_1._lr_right) + (arg_376_0.choked_commands == 0 and (arg_376_1._at_target_offset or 0) or 0)
	end

	arg_376_1.body_yaw_options = {}

	if arg_376_2.freestand_peek then
		arg_376_1.freestand_peek = arg_376_2.freestand_peek:get()
	end
end

function bs_aa_updater.update_modifier(arg_377_0, arg_377_1, arg_377_2, arg_377_3)
	bs_v1106 = arg_377_2.modifier:get()
	bs_v1107 = arg_377_2.modifier_mode:get()
	bs_v1108 = arg_377_2.randomize:get()
	bs_v1109 = arg_377_2.modifier_offset:get()
	bs_v1110 = arg_377_2.modifier_custom_sliders:get()
	bs_v1111 = math.max(arg_377_2["modifier_sliders_" .. (bs_v88[arg_377_3] or 1)]:get() or 1, 1)

	-- Aesthetic beta async applies offset directly; don't stack yaw modifier/extra offset on top
	if arg_377_1 and arg_377_1._async_yaw_active then
		arg_377_1.yaw_modifier = "Disabled"
		arg_377_1.modifier_offset = 0
		arg_377_1.way = nil
		return
	end

	if not bs_v1108 then
		if bs_v1106 == "center" then
			arg_377_1.yaw_modifier = "Center"
			arg_377_1.modifier_offset = bs_v1109

			return
		elseif bs_v1106 == "offset" then
			arg_377_1.yaw_modifier = "Offset"
			arg_377_1.modifier_offset = bs_v1109

			return
		elseif bs_v1106 == "random" then
			arg_377_1.yaw_modifier = "Random"
			arg_377_1.modifier_offset = bs_v1109

			return
		elseif bs_v1106 == "spin" then
			arg_377_1.yaw_modifier = "Spin"
			arg_377_1.modifier_offset = bs_v1109

			return
		elseif bs_v1106 == "skitter" then
			if arg_377_0.choked_commands == 0 then
				bs_v136[arg_377_3] = (bs_v136[arg_377_3] + 1) % 65535
			end

			bs_v1084 = {
				-1,
				1,
				0,
				-1,
				1,
				0,
				-1,
				0,
				1,
				-1,
				0,
				1
			}
			bs_v1092 = arg_377_2.skitter_deg and arg_377_2.skitter_deg:get() or 45
			bs_v1101 = bs_v1084[bs_v136[arg_377_3] % #bs_v1084 + 1]
-- Use modifier_offset instead of modifying yaw_offset directly (prevents double application)
            arg_377_1.yaw_modifier = "Offset"
            arg_377_1.modifier_offset = bs_v1092 * bs_v1101

            return
        end
    end

    if bs_v1106 == "skitter" then
		if arg_377_0.choked_commands == 0 then
			bs_v136[arg_377_3] = (bs_v136[arg_377_3] + 1) % 65535
		end

		bs_v1083 = {
			-1,
			1,
			0,
			-1,
			1,
			0,
			-1,
			0,
			1,
			-1,
			0,
			1
		}
		bs_v1091 = arg_377_2.skitter_deg and arg_377_2.skitter_deg:get() or 45
		bs_v1100 = bs_v1083[bs_v136[arg_377_3] % #bs_v1083 + 1]
-- Use modifier_offset instead of modifying yaw_offset directly
        arg_377_1.yaw_modifier = "Offset"
        arg_377_1.modifier_offset = bs_v1091 * bs_v1100

        return
    end

	if arg_377_0.choked_commands == 0 then
		bs_v73[arg_377_3] = (bs_v73[arg_377_3] or 1) + 1

		if bs_v73[arg_377_3] >= 7 then
			bs_v73[arg_377_3] = 1
		end

		bs_v119[arg_377_3] = (bs_v119[arg_377_3] or 0) + 1

		if bs_v1106 == "dual" then
			bs_v1082 = arg_377_2.dual_distribution and arg_377_2.dual_distribution:get() or "alternate"
			bs_v1090 = arg_377_2.dual_rate and arg_377_2.dual_rate:get() or 2
			bs_v1096 = arg_377_2.dual_rate_b and arg_377_2.dual_rate_b:get() or 4

			if bs_v1082 == "random" then
				bs_v154[arg_377_3] = math.random(0, 1)
			elseif bs_v1082 == "pulse" then
				if (bs_v154[arg_377_3] or 0) == 0 then
					bs_v179[arg_377_3] = (bs_v179[arg_377_3] or 0) + 1

					if bs_v1090 <= bs_v179[arg_377_3] then
						bs_v179[arg_377_3] = 0
						bs_v154[arg_377_3] = 1
					end
				else
					bs_v201[arg_377_3] = (bs_v201[arg_377_3] or 0) + 1

					if bs_v1096 <= bs_v201[arg_377_3] then
						bs_v201[arg_377_3] = 0
						bs_v154[arg_377_3] = 0
					end
				end
			else
				bs_v179[arg_377_3] = (bs_v179[arg_377_3] or 0) + 1

				if bs_v1090 <= bs_v179[arg_377_3] then
					bs_v179[arg_377_3] = 0
					bs_v154[arg_377_3] = bs_v154[arg_377_3] == 0 and 1 or 0
				end
			end
		end
	end

	function bs_v1081(arg_378_0)
		local var_378_0 = bs_v154[arg_377_3] or 0
		local var_378_1 = arg_377_2.dual_left_off and arg_377_2.dual_left_off:get() or -60
		local var_378_2 = arg_377_2.dual_right_off and arg_377_2.dual_right_off:get() or 60

		return (var_378_0 == 0 and var_378_1 or var_378_2) + (arg_378_0 or 0)
	end

	if bs_v1108 then
		if bs_v1107 == "uniform" then
			bs_v1089 = math.random(arg_377_2.min:get(), arg_377_2.max:get())
			arg_377_1.modifier_offset = bs_v1106 == "chaos" and bs_aa_updater.get_exploit_values(bs_v1089, bs_v73[arg_377_3]) or bs_v1106 == "dual" and bs_v1081(bs_v1089) or bs_v1089
		elseif bs_v1107 == "weighted" then
			bs_v1088 = arg_377_2.modifier_weight_center and arg_377_2.modifier_weight_center:get() or 50
			bs_v1095 = arg_377_2.modifier_weight_spread and arg_377_2.modifier_weight_spread:get() or 60
			bs_v1099 = bs_v1088 / 100 * 2 - 1
			bs_v1104 = bs_v1099 + (math.random() - 0.5) * (1 - math.abs(bs_v1099) * 0.5) * 2
			bs_v1103 = math.max(-1, math.min(1, bs_v1104))
			bs_v1105 = math.floor(bs_v1103 * bs_v1095)
			arg_377_1.modifier_offset = bs_v1106 == "chaos" and bs_aa_updater.get_exploit_values(bs_v1105, bs_v73[arg_377_3]) or bs_v1106 == "dual" and bs_v1081(bs_v1105) or bs_v1105
		elseif bs_v1107 == "pulse" then
			bs_v1087 = arg_377_2.modifier_pulse_a and arg_377_2.modifier_pulse_a:get() or -60
			bs_v1094 = arg_377_2.modifier_pulse_b and arg_377_2.modifier_pulse_b:get() or 60
			bs_v1098 = arg_377_2.modifier_pulse_rate and arg_377_2.modifier_pulse_rate:get() or 8
			bs_v1102 = bs_v1098 > bs_v119[arg_377_3] % (bs_v1098 * 2) and bs_v1087 or bs_v1094
			arg_377_1.modifier_offset = bs_v1106 == "chaos" and bs_aa_updater.get_exploit_values(bs_v1102, bs_v73[arg_377_3]) or bs_v1106 == "dual" and bs_v1081(bs_v1102) or bs_v1102
		elseif bs_v1107 == "custom" then
			if arg_377_0.choked_commands == 0 then
				bs_v103[arg_377_3] = (bs_v103[arg_377_3] or 0) + 1

				if bs_v1111 <= (bs_v103[arg_377_3] or 0) then
					bs_v103[arg_377_3] = 0
					bs_v88[arg_377_3] = (bs_v88[arg_377_3] or 0) + 1

					if bs_v1110 < bs_v88[arg_377_3] then
						bs_v88[arg_377_3] = 1
					end
				end
			end

			bs_v1086 = arg_377_2["modifier_sliders_" .. bs_v88[arg_377_3]]:get()
			arg_377_1.modifier_offset = bs_v1106 == "chaos" and bs_aa_updater.get_exploit_values(bs_v1086, bs_v73[arg_377_3]) or bs_v1106 == "dual" and bs_v1081(bs_v1086) or bs_v1086
		end
	elseif bs_v1106 == "dual" then
		bs_v1085 = bs_v154[arg_377_3] or 0
		bs_v1093 = arg_377_2.dual_left_off and arg_377_2.dual_left_off:get() or -60
		bs_v1097 = arg_377_2.dual_right_off and arg_377_2.dual_right_off:get() or 60
		arg_377_1.modifier_offset = bs_v1085 == 0 and bs_v1093 or bs_v1097
	elseif bs_v1106 == "chaos" then
		arg_377_1.modifier_offset = bs_aa_updater.get_exploit_values(arg_377_2.chaos_range and arg_377_2.chaos_range:get() or 60, bs_v73[arg_377_3])
	else
		arg_377_1.modifier_offset = bs_v1109
	end

if bs_v1106 == "chaos" then
		arg_377_1.yaw_modifier = "3-Way"
	 elseif bs_v1106 == "dual" then
		arg_377_1.yaw_modifier = "3-Way"
	 elseif bs_v1106 == "3-way" then
		arg_377_1.yaw_modifier = "3-Way"
	 elseif bs_v1106 == "5-way" then
		arg_377_1.yaw_modifier = "5-Way"
	 elseif bs_v1106 == "center" then
		arg_377_1.yaw_modifier = "Center"
	 elseif bs_v1106 == "offset" then
		arg_377_1.yaw_modifier = "Offset"
	 elseif bs_v1106 == "random" then
		arg_377_1.yaw_modifier = "Random"
	 elseif bs_v1106 == "spin" then
		arg_377_1.yaw_modifier = "Spin"
	 elseif bs_v1106 == "skitter" then
		arg_377_1.yaw_modifier = "Offset"
	 else
		arg_377_1.yaw_modifier = "Disabled"
	 end
end

function bs_v464(arg_379_0, arg_379_1)
	bs_v444 = bs_hit_result()
	bs_v448 = arg_379_0
	bs_v452 = arg_379_1
	bs_v432 = arg_379_0
	bs_v436 = 0
	bs_v440 = 0

	local var_379_0 = entity.get_local_player()

	if var_379_0 and var_379_0:is_alive() then
		local var_379_1 = var_379_0:get_origin()
		local var_379_2 = 0

		pcall(function()
			local var_380_0 = rage.antiaim:get_target()

			if var_380_0 then
				var_379_2 = var_380_0 * math.pi / 180
			end
		end)

		bs_shot_record.fired = true
		bs_shot_record.ox = var_379_1.x
		bs_shot_record.oy = var_379_1.y
		bs_shot_record.oz = var_379_1.z
		bs_shot_record.yaw = var_379_2
	end
end

bs_v466 = 0
bs_v468 = 0
bs_v470 = 1
bs_v472 = true

function bs_v474(arg_381_0)
	bs_v1112 = bs_menu.antiaim.general.reset_aa_trace

	if not bs_v1112 or not bs_v1112.twist:get() then
		bs_v432 = 0
		bs_v466 = 0

		return
	end

	if bs_defensive_mgr.is_active then
		bs_v432 = 0
		bs_v466 = 0

		return
	end

	if bs_legit_aa.is_working then
		bs_v432 = 0
		bs_v466 = 0

		return
	end

-- Trigger safe head on weapon switch / reload game events
	local var_381_2_0 = bs_menu.antiaim.general.break_lc
	if var_381_2_0 and var_381_2_0.events and bs_break_lc_evt(var_381_2_0) and bs_v466 <= 0 then
		bs_v472 = true
		bs_v432 = 0
		bs_v466 = 18
		bs_v468 = 0
		bs_v470 = bs_hit_result()

		return
	end

	bs_v1117, bs_v1118 = pcall(function()
		return bs_safe_head.think(arg_381_0)
	end)

	if bs_v1117 and bs_v1118 then
		bs_v432 = 0
		bs_v466 = 0

		return
	end

	if bs_manual_yaw.think() then
		bs_v432 = 0
		bs_v466 = 0

		return
	end

	if bs_freestanding.think() then
		bs_v432 = 0
		bs_v466 = 0

		return
	end

	bs_v1119 = entity.get_local_player()

	if bs_v1119 and bs_v1119:is_alive() then
		bs_v1121, bs_v1123 = pcall(function()
			return bs_v1119:get_anim_state()
		end)

		if bs_v1121 and bs_v1123 then
			bs_v1125 = bs_v1123.on_ground

			if bs_v1125 and not bs_v472 and bs_v466 <= 0 and bs_v432 <= 0 then
				bs_v470 = bs_hit_result()
				bs_v466 = 18
				bs_v468 = 0
				bs_v1129 = bs_v1119:get_origin()
				bs_v1114 = 0

				pcall(function()
					local var_384_0 = rage.antiaim:get_target()

					if var_384_0 then
						bs_v1114 = var_384_0 * math.pi / 180
					end
				end)

				bs_shot_record.fired = true
				bs_shot_record.ox = bs_v1129.x
				bs_shot_record.oy = bs_v1129.y
				bs_shot_record.oz = bs_v1129.z
				bs_shot_record.yaw = bs_v1114
				bs_v472 = true
			end

			if not bs_v1125 then
				bs_v472 = false
			end
		end
	end

	if bs_v432 <= 0 then
		return
	end

	bs_v1120 = bs_v448
	bs_v1122 = bs_v452
	bs_v440 = bs_v440 + 1
	bs_v432 = bs_v432 - 1
	bs_v1124 = bs_v440 / math.max(1, bs_v1120)
	bs_v1126 = math.max(0, math.min(1, bs_v1124))
	bs_v1128 = bs_v1126 * bs_v1126 * bs_v1126 * (bs_v1126 * (bs_v1126 * 6 - 15) + 10)
	bs_v1127 = math.sin(bs_v1128 * math.pi)
	bs_v1113 = 0.9
	bs_v1115 = math.sin(bs_v1124 * math.pi * bs_v1113 * 2)
	bs_v1116 = bs_v444 * bs_v1127 * bs_v1115 * bs_v1122

	bs_config.antiaim.angles.hidden:override(true)
	rage.antiaim:override_hidden_pitch(89)
	rage.antiaim:override_hidden_yaw_offset(bs_v1116)

	if bs_v432 == 0 then
		if not bs_defensive_mgr.def_ind_latch.is_working then
			bs_config.antiaim.angles.hidden:override()
		end

		rage.antiaim:override_hidden_pitch(0)
		rage.antiaim:override_hidden_yaw_offset(0)
	end
end

-- Fakelag manager: disables fake lag while double-tapping, hiding shots, or moving
-- slowly (and not in a defensive state), then forces the fake lag limit to at least
-- 14 ticks so the choke stays consistent with the anti-aim.
-- #############################################################################
-- #  [SEC-17] FAKELAG MANAGER
-- #############################################################################
function update_fakelag(_cmd)
	local player = entity.get_local_player()

	if not player or not player:is_alive() then
		return
	end

	local velocity = player.m_vecVelocity and player.m_vecVelocity:length2d() or 0
	local is_double_tap = false
	local is_hide_shots = false

	pcall(function()
		is_double_tap = bs_config.rage.main.double_tap:get()
	end)
	pcall(function()
		is_hide_shots = bs_config.rage.main.hide_shots:get()
	end)

	local debug_state = bs_defensive_mgr and bs_defensive_mgr.get_debug_state and bs_defensive_mgr.get_debug_state() or {}

	-- Disable fake lag when DT/HS is active, velocity is below ~1.11, and we are
	-- not currently in a defensive state.
	if (is_double_tap or is_hide_shots or velocity < 1.11) and not debug_state.defensive and not bs_defensive_mgr.is_active then
		bs_config.antiaim.fake_lag.enabled_pui:override(false)
	else
		bs_config.antiaim.fake_lag.enabled_pui:override()
	end

	-- Keep the fake lag limit at a minimum of 14 ticks.
	pcall(function()
		if bs_config.antiaim.fake_lag.limit_pui:get() < 14 then
			bs_config.antiaim.fake_lag.limit_pui:set(14)
		end
	end)
end

-- #############################################################################
-- #  [SEC-18] ANTI-AIM MAIN UPDATE (ORCHESTRATOR)
-- #############################################################################
function bs_aa_updater.update(arg_389_0, arg_389_1, arg_389_2)
	update_fakelag(arg_389_0)
	bs_aa_state_obj:define()
	pcall(function()
		bs_config.antiaim.angles.hidden:override(false)
	end)

	bs_safe_head.active = false

	bs_break_lc.handle_normal(arg_389_0, bs_aa_state_obj)

	bs_v1138 = bs_aa_updater.get_preset(arg_389_1)

	if bs_v1138 == nil then
		if bs_defensive_mgr then bs_defensive_mgr.is_active = false end
		bs_legit_aa.is_working = false
		pcall(function()
			rage.antiaim:override_hidden_pitch(0)
			rage.antiaim:override_hidden_yaw_offset(0)
			bs_config.antiaim.fake_lag.limit:override(nil)
			bs_config.antiaim.angles.pitch:override("Disabled")
			bs_config.antiaim.angles.yaw:override("disabled")
			bs_config.antiaim.angles.yaw_add:override(0)
			bs_config.antiaim.angles.yaw_base:override("Local View")
			bs_config.antiaim.angles.yaw_modifier:override("Disabled")
			bs_config.antiaim.angles.modifier_offset:override(0)
			bs_config.antiaim.angles.body_yaw:override(false)
			bs_config.antiaim.angles.inverter:override(false)
			bs_config.antiaim.angles.left_limit:override(0)
			bs_config.antiaim.angles.right_limit:override(0)
			bs_config.antiaim.angles.options:override({})
			bs_config.antiaim.angles.disable_yaw_modifiers:override(false)
			bs_config.antiaim.angles.body_freestanding:override(false)
			bs_config.antiaim.angles.freestanding:override(false)
			bs_config.antiaim.angles.freestand_peek:override("Off")
			bs_config.antiaim.angles.avoid_backstab:override(false)
			bs_config.rage.main.double_tap_lag_options:override("On Peek")
			bs_config.rage.main.hide_shots_options:override("Favor Fire Rate")
		end)
		return
	end

	if not bs_v1138.allow_state:get() then
		bs_aa_state_obj:run()
		bs_v474(arg_389_0)
		if bs_defensive_mgr then bs_defensive_mgr.is_active = false end
		bs_legit_aa.is_working = false
		pcall(function()
			rage.antiaim:override_hidden_pitch(0)
			rage.antiaim:override_hidden_yaw_offset(0)
			bs_config.antiaim.fake_lag.limit:override(nil)
			bs_config.antiaim.angles.pitch:override("Disabled")
			bs_config.antiaim.angles.yaw:override("disabled")
			bs_config.antiaim.angles.yaw_add:override(0)
			bs_config.antiaim.angles.yaw_base:override("Local View")
			bs_config.antiaim.angles.yaw_modifier:override("Disabled")
			bs_config.antiaim.angles.modifier_offset:override(0)
			bs_config.antiaim.angles.body_yaw:override(false)
			bs_config.antiaim.angles.inverter:override(false)
			bs_config.antiaim.angles.left_limit:override(0)
			bs_config.antiaim.angles.right_limit:override(0)
			bs_config.antiaim.angles.options:override({})
			bs_config.antiaim.angles.disable_yaw_modifiers:override(false)
			bs_config.antiaim.angles.body_freestanding:override(false)
			bs_config.antiaim.angles.freestanding:override(false)
			bs_config.antiaim.angles.freestand_peek:override("Off")
			bs_config.antiaim.angles.avoid_backstab:override(false)
			bs_config.rage.main.double_tap_lag_options:override("On Peek")
			bs_config.rage.main.hide_shots_options:override("Favor Fire Rate")
		end)
		return
	end


	bs_aa_state_obj.avoid_backstab = bs_menu.antiaim.general.avoid_backstab.switch:get()

	bs_async_flip(arg_389_1)

	-- On-shot anti-brute trigger: fire ABF on the rising edge of in_attack (when we shoot)
	pcall(function()
	-- bs_v1138 is already builder[arg_389_1] (the active state's table); its .name is nil,
	-- so the old builder[bs_v1138.name] lookup always failed -> use it directly.
		local var_389_18_1 = bs_v1138

		if var_389_18_1 and var_389_18_1.abf_on_shot and var_389_18_1.abf_on_shot:get() and arg_389_0.in_attack and not bs_anti_brute.on_shot_last_attack then
			bs_v591({ name = "?", time = globals.curtime }, true, true)

			-- Log the on-shot bruteforce trigger (local shot)
			pcall(function()
				local var_389_18_2 = bs_menu.info and bs_menu.info.notify
				local var_389_18_3 = var_389_18_2 and var_389_18_2.col_abf_hit and var_389_18_2.col_abf_hit:get() or color(255, 160, 80, 255)
				bs_notify.new({
					"anti-bruteforce triggered by ",
					"local shot",
					" due to on-shot impact - angle shifted"
				}, var_389_18_3)
			end)
		end

		bs_anti_brute.on_shot_last_attack = arg_389_0.in_attack and true or false
	end)

	if arg_389_0.choked_commands == 0 then
		bs_v734 = not bs_v734
	end

	-- Evaluate safe head once. Elysian model: normal AA always runs; safe head is
	-- a defensive sub-state, so only body yaw is suppressed while it is active.
	local bs_safe_head_on = false
	pcall(function()
		bs_safe_head_on = bs_safe_head.think(arg_389_0)
	end)

	bs_aa_updater.update_yaw(arg_389_0, bs_aa_state_obj, bs_v1138, arg_389_1)

	-- Game Events Defensive: proper hold lifecycle
	-- Detect rising edge of event trigger, start hold with configured duration,
	-- keep Game Events profile active for hold duration even if signal disappears.
	-- Safe Head interrupts output but does not reset hold.
	local bs_lc_break_evt = false
	pcall(function()
		bs_lc_break_evt = bs_break_lc_evt(bs_menu.antiaim.general.break_lc) and bs_break_lc.think(arg_389_0)
	end)

	-- Rising-edge detection for new event activation
	local bs_ge_signal_now = bs_lc_break_evt
	local bs_ge_signal_was = bs_defensive_mgr.game_events_last_signal
	bs_defensive_mgr.game_events_last_signal = bs_ge_signal_now

	if bs_ge_signal_now and not bs_ge_signal_was then
		-- New event activation: read configured duration and start hold
		local bs_ge_settings = bs_menu.antiaim.defensive and bs_menu.antiaim.defensive.settings and bs_menu.antiaim.defensive.settings["game events"]
		local bs_ge_duration = bs_ge_settings and bs_ge_settings.def_duration and bs_ge_settings.def_duration:get() or 0
		if bs_ge_duration > 0 then
			bs_defensive_mgr.game_events_hold = bs_ge_duration
			bs_v316["game events"] = 0  -- fresh duration counter
		end
	end

	-- If hold active, force Game Events profile (priority over Legit AA, Safe Head for state selection)
	local bs_force_game_events = bs_defensive_mgr.game_events_hold > 0
	if bs_force_game_events then
		-- Decrement hold on non-choked commands (tick-accurate)
		if arg_389_0.choked_commands == 0 then
			bs_defensive_mgr.game_events_hold = bs_defensive_mgr.game_events_hold - 1
		end

		bs_defensive_mgr.is_active = false
		bs_legit_aa.is_working = false
		bs_aa_state_obj:run()
		bs_v474(arg_389_0)
		-- Force defensive to use game events state
		bs_break_lc.handle_normal(arg_389_0, bs_aa_state_obj)
		bs_defensive_mgr.update(arg_389_0, bs_aa_state_obj, "game events", bs_safe_head_on)
		bs_aa_state_obj:run()
		bs_v474(arg_389_0)

		return
	end

	-- Game events take priority over everything (original level-triggered branch for backward compat)
	if bs_lc_break_evt and not bs_safe_head_on then
		bs_defensive_mgr.is_active = false
		bs_legit_aa.is_working = false
		bs_aa_state_obj:run()
		bs_v474(arg_389_0)
		-- Force defensive to use game events state
		bs_break_lc.handle_normal(arg_389_0, bs_aa_state_obj)
		bs_defensive_mgr.update(arg_389_0, bs_aa_state_obj, "game events", false)
		bs_aa_state_obj:run()
		bs_v474(arg_389_0)

		return
	end

	bs_v1139 = bs_legit_aa.think(arg_389_0)
	bs_legit_aa.is_working = bs_v1139

	if bs_v1139 and not bs_safe_head_on then
		bs_legit_aa.update(arg_389_0, bs_aa_state_obj, bs_v1138)
		bs_defensive_mgr.update(arg_389_0, bs_aa_state_obj, arg_389_1, false)
		bs_aa_state_obj:run()
		bs_v474(arg_389_0)

		return
	end

	-- Defensive runs with safe_head_on so the defensive "safe head" profile
	-- (hidden pitch/yaw) still applies while safe head is the active sub-state.
	bs_v1142, bs_v1130 = bs_defensive_mgr.update(arg_389_0, bs_aa_state_obj, arg_389_1, bs_safe_head_on)
	pcall(function() bs_config.antiaim.fake_lag.limit:override(nil) end)

	-- Anti-brute must run AFTER yaw initialization and defensive evaluation,
	-- but BEFORE body yaw consumes _lr_left/_lr_right
	if not bs_v1142 and not bs_safe_head_on then
		bs_anti_brute.update(arg_389_0, bs_aa_state_obj, arg_389_1, bs_v1138)
	end

	if not bs_safe_head_on then
		bs_aa_updater.update_body_yaw(arg_389_0, bs_aa_state_obj, bs_v1138, arg_389_1)
	end

	bs_aa_updater.update_modifier(arg_389_0, bs_aa_state_obj, bs_v1138, arg_389_1)
	bs_break_lc.update(arg_389_0, bs_aa_state_obj, bs_v1138)

	local bs_fake_duck_on = false
	pcall(function()
		bs_fake_duck_on = bs_config.antiaim.misc.fake_duck:get()
	end)
	if bs_fake_duck_on then
		bs_v1142, bs_v1130 = false, false
		pcall(function()
			rage.antiaim:override_hidden_pitch(0)
			rage.antiaim:override_hidden_yaw_offset(0)
			bs_config.antiaim.fake_lag.limit:override(14)
		end)
		if bs_defensive_mgr then bs_defensive_mgr.is_active = false end
	else
		pcall(function() bs_config.antiaim.fake_lag.limit:override(nil) end)
	end

	-- Safe head runs last so it fully overrides the angle state.
	bs_v1140 = bs_safe_head.update(arg_389_0, bs_aa_state_obj, bs_v1138)

	bs_freestanding.get_side(arg_389_0)

	bs_v1131, bs_v1132, bs_v1133, bs_v1134 = bs_def_snap.think(arg_389_1)

	if bs_v1131 and not bs_v1140 then
		bs_def_snap.apply(arg_389_0, bs_aa_state_obj, bs_v1132, bs_v1133, bs_v1134)
	else
		bs_def_snap.active = false

		bs_def_snap.reset_snap()
	end

	-- Manual/freestanding run LAST so they always win (highest priority).
	-- Freestanding first, then manual (manual overrides freestanding if both active).
	bs_v1141 = bs_freestanding.think()

	if bs_v1141 then
		bs_freestanding.update(arg_389_0, bs_aa_state_obj, bs_v1138)
	end

	bs_manual_yaw.update(arg_389_0, bs_aa_state_obj, bs_v1138)

	bs_aa_state_obj:run()

	bs_v1135 = bs_menu.antiaim.general.freestanding

	if bs_v1135 and bs_v1135.static and bs_v1135.static:get() and bs_v1141 then
		bs_v1136 = rage.antiaim:get_target()
		bs_v1137 = rage.antiaim:get_target(true)

		if bs_v1136 and bs_v1137 and math.fmod(math.abs(bs_v1136 - bs_v1137), 360) > 5 then
			bs_config.antiaim.angles.body_yaw:override(false)
		end
	end
end

events.createmove(function(arg_391_0)
	local var_391_0 = entity.get_local_player()
	local var_391_1 = bs_legit_aa.think(arg_391_0)

	bs_aa_updater.update(arg_391_0, bs_get_state.get(var_391_1), var_391_0)
end)
events.round_start(function()
	bs_v416 = 0
	bs_v423 = 0
	bs_v428 = 0
	bs_v455 = 0
	bs_v432 = 0
	bs_v466 = 0
	bs_v468 = 0
	bs_v470 = 1
	bs_v472 = true
	bs_v477 = 0
	bs_v373 = 0
	ds_flip_at = 0
	ds_base_side = false
	ds_ghost_on = false
	bs_v391 = 0
	ds_flip_done = false
	bs_v436 = 0
	bs_v440 = 0
	bs_v444 = 1
	bs_v448 = 8
	bs_v452 = 58
	bs_v710 = false
	bs_v689 = 0
	bs_v700 = 0
	jitter_tick = 0
end)
events.player_death(function(arg_393_0)
	local var_393_0 = entity.get_local_player()

	if not var_393_0 then
		return
	end

	if entity.get(arg_393_0.userid, true) == var_393_0 then
		bs_v416 = 0
		bs_v423 = 0
		bs_v428 = 0
		bs_v455 = 0
		bs_v432 = 0
		bs_v373 = 0
		ds_flip_at = 0
		ds_base_side = false
		ds_ghost_on = false
		bs_v391 = 0
		ds_flip_done = false
		bs_v436 = 0
		bs_v440 = 0
		bs_v444 = 1
		bs_v448 = 8
		bs_v452 = 58
		bs_v710 = false
		bs_v689 = 0
		bs_v700 = 0
		jitter_tick = 0
	end
end)

bs_v669 = nil

events.createmove_run(function(arg_394_0)
	if not bs_menu.misc.movement.unlock_fd_speed:get() then
		return
	end

	if not bs_config.antiaim.misc.fake_duck:get() then
		return
	end

	local var_394_0 = arg_394_0.forwardmove
	local var_394_1 = arg_394_0.sidemove

	if math.abs(var_394_0) > 5 or math.abs(var_394_1) > 5 then
		local var_394_2 = 450 / (var_394_0 * var_394_0 + var_394_1 * var_394_1)^0.5

		arg_394_0.forwardmove = var_394_0 * var_394_2
		arg_394_0.sidemove = var_394_1 * var_394_2
	end
end)

bs_v677 = nil
bs_v686 = utils.opcode_scan("engine.dll", "FF E1")
bs_v699 = utils.opcode_scan("engine.dll", "FF 15 ? ? ? ? A3 ? ? ? ? EB 05")
bs_v709 = utils.opcode_scan("engine.dll", "FF 15 ? ? ? ? 85 C0 74 0B")

if bs_v686 and bs_v699 and bs_v709 then
	bs_v720 = ffi.cast("uint32_t(__fastcall*)(unsigned int,unsigned int,const char*)", bs_v686)
	bs_v733 = ffi.cast("uint32_t(__fastcall*)(unsigned int,unsigned int,uint32_t,const char*)", bs_v686)
	bs_v745 = ffi.cast("uint32_t**", ffi.cast("uint32_t", bs_v699) + 2)[0][0]
	bs_v755 = ffi.cast("uint32_t**", ffi.cast("uint32_t", bs_v709) + 2)[0][0]
	bs_v12 = (function(arg_395_0, arg_395_1, arg_395_2)
		local var_395_0 = ffi.typeof(arg_395_2)

		return function(...)
			return ffi.cast(var_395_0, bs_v686)(bs_v733(bs_v745, 0, bs_v720(bs_v755, 0, arg_395_0), arg_395_1), 0, ...)
		end
	end)("user32.dll", "EnumDisplaySettingsA", "int(__fastcall*)(unsigned int,unsigned int,unsigned int,unsigned long,void*)")
	bs_v27 = ffi.new("struct { char pad_0[120]; unsigned long dmDisplayFrequency; char pad_2[32]; }[1]")

	bs_v12(0, 4294967295, bs_v27[0])
end

bs_v685 = nil
bs_v695 = {
	[0] = "generic",
	"head",
	"chest",
	"stomach",
	"left arm",
	"right arm",
	"left leg",
	"right leg",
	"neck",
	"generic",
	"gear"
}

function bs_v706(arg_397_0, arg_397_1)
	return "\a" .. arg_397_1 .. arg_397_0 .. "\aDEFAULT"
end

bs_v719 = {}
bs_v732 = 4.5
bs_v744 = 6
bs_v754 = 6
bs_v765 = 16
bs_v11 = 14

-- #############################################################################
-- #  [SEC-19] RUNTIME / VISUALS / EVENT HANDLERS
-- #############################################################################
function bs_v26(arg_398_0, arg_398_1, arg_398_2)
	-- arg_398_2 (optional): target key. When given, any existing notification for
	-- the SAME target is dropped first so only the latest shot's line (and its
	-- backtrack tick count) stays on screen. This keeps the indicator in sync
	-- with the console, which only ever prints the most recent shot.
	if arg_398_2 ~= nil then
		for i = #bs_v719, 1, -1 do
			if bs_v719[i].target_key == arg_398_2 then
				table.remove(bs_v719, i)
			end
		end
	end

	if #bs_v719 >= bs_v11 then
		table.remove(bs_v719, 1)
	end

	table.insert(bs_v719, {
		parts = arg_398_0,
		born = globals.realtime,
		dur = arg_398_1 or bs_v732,
		target_key = arg_398_2
	})
end

bs_v481 = bs_v26

events.render(function()
	local var_399_0 = bs_menu.info and bs_menu.info.notify

	if not var_399_0 or not var_399_0.log_enabled:get() then
		return
	end

	local var_399_1, var_399_2 = pcall(function()
		return var_399_0.log_mode:get()
	end)

	if not var_399_1 or var_399_2 ~= "text" then
		return
	end

	local var_399_3 = globals.realtime
	local var_399_4 = 1
	local var_399_5 = bs_v754
	local var_399_6 = 1

	while var_399_6 <= #bs_v719 do
		local var_399_7 = bs_v719[var_399_6]
		local var_399_8 = var_399_3 - var_399_7.born

		if var_399_8 > var_399_7.dur then
			table.remove(bs_v719, var_399_6)
		else
			local var_399_9 = 1
			local var_399_10 = var_399_7.dur - 0.8

			if var_399_10 < var_399_8 then
				var_399_9 = math.max(0, 1 - (var_399_8 - var_399_10) / 0.8)
			end

			local var_399_11 = bs_v744

			for iter_399_0, iter_399_1 in ipairs(var_399_7.parts) do
				local var_399_12 = iter_399_1[1]
				local var_399_13 = tostring(iter_399_1[2])
				local var_399_14 = color(var_399_12.r, var_399_12.g, var_399_12.b, math.floor(var_399_12.a * var_399_9))

				render.text(var_399_4, vector(var_399_11, var_399_5), var_399_14, nil, var_399_13)

				var_399_11 = var_399_11 + render.measure_text(var_399_4, nil, var_399_13).x
			end

			var_399_5 = var_399_5 + bs_v765
			var_399_6 = var_399_6 + 1
		end
	end
end)
events.aim_ack(function(arg_401_0)
	bs_v1143 = bs_menu.info.notify

	if not bs_v1143.log_enabled:get() then
		return
	end

	bs_v1169 = entity.get_local_player()

	if bs_v1169 == nil or not bs_v1169:is_alive() then
		return
	end

	bs_v1170 = arg_401_0.target

	if bs_v1170 == nil then
		return
	end

	-- Target key for de-duplicating on-screen notifications (see bs_v26). Uses
	-- the entity index so rapid shots at the same enemy replace the previous
	-- line instead of stacking, keeping the shown backtrack ticks in sync with
	-- the console (which only ever prints the most recent shot).
	bs_v1170_key = nil
	pcall(function() bs_v1170_key = bs_v1170:get_index() end)
	if bs_v1170_key == nil then
		pcall(function() bs_v1170_key = string.lower(bs_v1170:get_name()) end)
	end

	bs_v1171, bs_v1172 = pcall(function()
		return bs_v1143.log_mode:get()
	end)
	bs_v1173 = bs_v1171 and bs_v1172 == "text"
	bs_v1174 = color(180, 180, 185, 255)

	if arg_401_0.state == nil then
		if not bs_v1143.log_hits:get() then
			return
		end

		bs_v1176 = bs_v695[arg_401_0.hitgroup] or "generic"
		bs_v1178 = bs_v695[arg_401_0.wanted_hitgroup] or "generic"
		bs_v1145 = arg_401_0.hitgroup == arg_401_0.wanted_hitgroup
		bs_v1147 = arg_401_0.damage == arg_401_0.wanted_damage
		bs_v1149, bs_v1151 = pcall(function()
			return bs_v1143.col_mismatch:get()
		end)

		if not bs_v1149 then
			bs_v1151 = color(255, 159, 94, 255)
		end

		bs_v1153 = (not bs_v1145 or not bs_v1147) and bs_v1151 or bs_v1143.col_hit:get()
		bs_v1155 = math.floor(arg_401_0.backtrack * globals.tickinterval * 1000 + 0.5)

		if bs_v1173 then
			bs_v1157 = {
				{
					bs_v1153,
					bs_v1
				},
				{
					bs_v1174,
					" · hit "
				},
				{
					bs_v1153,
					string.lower(bs_v1170:get_name())
				},
				{
					bs_v1174,
					"'s "
				},
				{
					bs_v1153,
					bs_v1176
				},
				{
					bs_v1174,
					" for "
				},
				{
					bs_v1153,
					tostring(arg_401_0.damage)
				},
				{
					bs_v1174,
					" damage ( hc ~ "
				},
				{
					bs_v1153,
					tostring(arg_401_0.hitchance) .. "%"
				},
				{
					bs_v1174,
					" / bt ~ "
				},
				{
					bs_v1153,
					tostring(arg_401_0.backtrack) .. "ticks"
				}
			}

			if not bs_v1145 then
				table.insert(bs_v1157, {
					bs_v1174,
					" / mismatched hg ~ "
				})
				table.insert(bs_v1157, {
					bs_v1151,
					bs_v1176 .. "(" .. bs_v1178 .. ")"
				})
			end

			if not bs_v1147 then
				table.insert(bs_v1157, {
					bs_v1174,
					" / mismatched dmg ~ "
				})
				table.insert(bs_v1157, {
					bs_v1151,
					tostring(arg_401_0.damage) .. "(" .. tostring(arg_401_0.wanted_damage) .. ")"
				})
			end

			table.insert(bs_v1157, {
				bs_v1174,
				" )"
			})
			bs_v26(bs_v1157, nil, bs_v1170_key)
		else
			bs_notify.new({
				"hit ",
				string.lower(bs_v1170:get_name()),
				"'s ",
				bs_v1176,
				" for ",
				arg_401_0.damage,
				" dmg"
			}, bs_v1153)
		end

		if bs_v1143.log_console:get() then
			bs_v1156 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
			bs_v1162 = bs_v706(string.lower(bs_v1170:get_name()), bs_v1153:to_hex())
			bs_v1166 = bs_v1145 and "" or " / mismatched hg ~ " .. bs_v1176 .. "(" .. bs_v1178 .. ")"
			bs_v1168 = bs_v1147 and "" or " / mismatched dmg ~ " .. tostring(arg_401_0.damage) .. "(" .. tostring(arg_401_0.wanted_damage) .. ")"

			print_raw(("%s · hit %s's %s for %s damage ( HC ~ %s%% / R.HC ~ %s%% / bt ~ %sticks%s%s )"):format(bs_v1156, bs_v1162, bs_v1176, tostring(arg_401_0.damage), tostring(bs_active_hc_value or 0), tostring(arg_401_0.hitchance), tostring(arg_401_0.backtrack), bs_v1166, bs_v1168))
		end
	else
		if not bs_v1143.log_misses:get() then
			return
		end

		bs_v1175 = bs_v1143.col_miss:get()
		bs_v1177, bs_v1144 = pcall(function()
			return bs_v1143.col_miss_mismatch:get()
		end)

		if not bs_v1177 then
			bs_v1144 = color(255, 159, 94, 255)
		end

		bs_v1146 = bs_v695[arg_401_0.wanted_hitgroup] or "generic"
		bs_v1148 = bs_v695[arg_401_0.hitgroup] or nil
		bs_v1150 = bs_v1148 == nil or arg_401_0.hitgroup == arg_401_0.wanted_hitgroup
		bs_v1152 = not bs_v1150 and bs_v1144 or bs_v1175
		bs_v1154 = string.lower(bs_v1170:get_name())

		if arg_401_0.state == "player death" or arg_401_0.state == "death" then
			if bs_v1173 then
				bs_v1161 = {
					{
						bs_v1152,
						bs_v1
					},
					{
						bs_v1174,
						" · missed "
					},
					{
						bs_v1152,
						bs_v1154
					},
					{
						bs_v1174,
						"'s "
					},
					{
						bs_v1152,
						bs_v1146
					},
					{
						bs_v1174,
						" ( missed due to death )"
					}
				}

				bs_v26(bs_v1161, nil, bs_v1170_key)
			else
				bs_notify.new({
					"missed ",
					bs_v1154,
					"'s ",
					bs_v1146,
					" — died"
				}, bs_v1175)
			end

			if bs_v1143.log_console:get() then
				bs_v1160 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
				bs_v1165 = bs_v706(bs_v1154, bs_v1175:to_hex())

				print_raw(("%s · missed %s's %s ( missed due to death )"):format(bs_v1160, bs_v1165, bs_v1146))
			end

			return
		end

		if bs_v1173 then
			bs_v1159 = math.floor((arg_401_0.backtrack or 0) * globals.tickinterval * 1000 + 0.5)
			bs_v1164 = {
				{
					bs_v1152,
					bs_v1
				},
				{
					bs_v1174,
					" · missed "
				},
				{
					bs_v1152,
					bs_v1154
				},
				{
					bs_v1174,
					"'s "
				},
				{
					bs_v1152,
					bs_v1146
				},
				{
					bs_v1174,
					" due to "
				},
				{
					bs_v1152,
					tostring(arg_401_0.state)
				},
				{
					bs_v1174,
					" ( hc ~ "
				},
				{
					bs_v1152,
					tostring(arg_401_0.hitchance) .. "%"
				},
				{
					bs_v1174,
					" / dmg ~ "
				},
				{
					bs_v1152,
					tostring(arg_401_0.wanted_damage)
				},
				{
					bs_v1174,
					" / bt ~ "
				},
				{
					bs_v1152,
					tostring(arg_401_0.backtrack or 0) .. "ticks"
				}
			}

			if not bs_v1150 then
				table.insert(bs_v1164, {
					bs_v1174,
					" / mismatched hg ~ "
				})
				table.insert(bs_v1164, {
					bs_v1144,
					bs_v1146 .. "(" .. bs_v1148 .. ")"
				})
			end

			table.insert(bs_v1164, {
				bs_v1174,
				" )"
			})
			bs_v26(bs_v1164, nil, bs_v1170_key)
		else
			bs_notify.new({
				"missed ",
				bs_v1154,
				" in ",
				bs_v1146,
				" — ",
				arg_401_0.state
			}, bs_v1175)
		end

		if bs_v1143.log_console:get() then
			bs_v1158 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
			bs_v1163 = bs_v706(bs_v1154, bs_v1175:to_hex())
			bs_v1167 = bs_v1150 and "" or " / mismatched hg ~ " .. bs_v1146 .. "(" .. (bs_v1148 or "?") .. ")"

			print_raw(("%s · missed %s's %s due to %s ( HC ~ %s%% / R.HC ~ %s%% / dmg ~ %s / bt ~ %sticks%s )"):format(bs_v1158, bs_v1163, bs_v1146, tostring(arg_401_0.state), tostring(bs_active_hc_value or 0), tostring(arg_401_0.hitchance), tostring(arg_401_0.wanted_damage), tostring(arg_401_0.backtrack or 0), bs_v1167))
		end
	end
end)

bs_v39 = {}
bs_v54 = {}

events.player_hurt(function(arg_405_0)
	bs_v1179 = bs_menu.info and bs_menu.info.notify

	if not bs_v1179 or not bs_v1179.log_enabled:get() then
		return
	end

	if not bs_v1179.log_hits:get() then
		return
	end

	bs_v1190 = entity.get_local_player()

	if not bs_v1190 or not bs_v1190:is_alive() then
		return
	end

	if entity.get(arg_405_0.attacker, true) ~= bs_v1190 then
		return
	end

	bs_v1204 = tostring(arg_405_0.weapon or "")
	bs_v1205 = bs_v1204 == "hegrenade"
	bs_v1206 = bs_v1204 == "inferno"
	bs_v1207 = bs_v1204 == "knife" or bs_v1204 == "knife_t" or bs_v1204 == "knifegg" or bs_v1204:find("knife") ~= nil

	if not bs_v1205 and not bs_v1206 and not bs_v1207 then
		return
	end

	bs_v1208 = entity.get(arg_405_0.userid, true)

	if not bs_v1208 then
		return
	end

	bs_v1209, bs_v1180 = pcall(function()
		return bs_v1208:get_name()
	end)
	bs_v1181 = string.lower(string.sub(bs_v1209 and bs_v1180 or "unknown", 1, 15))
	bs_v1182 = arg_405_0.dmg_health
	bs_v1183 = arg_405_0.health
	bs_v1184, bs_v1185 = pcall(function()
		return bs_v1179.log_mode:get()
	end)
	bs_v1186 = bs_v1184 and bs_v1185 == "text"
	bs_v1187 = color(180, 180, 185, 255)
	bs_v1188 = bs_v1205 and "naded" or bs_v1206 and "burned" or "knifed"
	bs_v1189 = bs_v1179.col_hit:get()

	if bs_v1206 then
		bs_v1194 = globals.realtime

		if bs_v1186 then
			bs_v1198 = bs_v39[bs_v1181]

			if bs_v1198 and bs_v1198.entry and bs_v1194 - bs_v1198.entry.born < bs_v1198.entry.dur then
				bs_v1198.total_dmg = bs_v1198.total_dmg + bs_v1182
				bs_v1198.entry.born = bs_v1194
				bs_v1198.entry.parts = {
					{
						bs_v1189,
						bs_v1
					},
					{
						bs_v1187,
						" · "
					},
					{
						bs_v1187,
						bs_v1188
					},
					{
						bs_v1187,
						" "
					},
					{
						bs_v1189,
						bs_v1181
					},
					{
						bs_v1187,
						" for "
					},
					{
						bs_v1189,
						tostring(bs_v1198.total_dmg)
					},
					{
						bs_v1187,
						" dmg ( left ~ "
					},
					{
						bs_v1189,
						tostring(bs_v1183)
					},
					{
						bs_v1187,
						" )"
					}
				}
			else
				bs_v1201 = {
					{
						bs_v1189,
						bs_v1
					},
					{
						bs_v1187,
						" · "
					},
					{
						bs_v1187,
						bs_v1188
					},
					{
						bs_v1187,
						" "
					},
					{
						bs_v1189,
						bs_v1181
					},
					{
						bs_v1187,
						" for "
					},
					{
						bs_v1189,
						tostring(bs_v1182)
					},
					{
						bs_v1187,
						" dmg ( left ~ "
					},
					{
						bs_v1189,
						tostring(bs_v1183)
					},
					{
						bs_v1187,
						" )"
					}
				}
				bs_v1203 = {
					parts = bs_v1201,
					born = bs_v1194,
					dur = bs_v732
				}

				if #bs_v719 >= bs_v11 then
					table.remove(bs_v719, 1)
				end

				table.insert(bs_v719, bs_v1203)

				bs_v39[bs_v1181] = {
					entry = bs_v1203,
					total_dmg = bs_v1182
				}
			end
		else
			bs_v1197 = bs_v54[bs_v1181]

			if bs_v1197 and not bs_v1197.dying then
				bs_v1197.total_dmg = (bs_v1197.total_dmg or 0) + bs_v1182
				bs_v1197.born = bs_v1194
				bs_v1197.parts = {
					bs_v1188 .. " " .. bs_v1181 .. " for " .. tostring(bs_v1197.total_dmg) .. " dmg",
					" ( left ~ " .. tostring(bs_v1183) .. " )"
				}
			else
				bs_v1200 = {
					bs_v1188 .. " " .. bs_v1181 .. " for " .. tostring(bs_v1182) .. " dmg",
					" ( left ~ " .. tostring(bs_v1183) .. " )"
				}
				bs_v1202 = bs_notify.new(bs_v1200, bs_v1189)
				bs_v1202.total_dmg = bs_v1182
				bs_v54[bs_v1181] = bs_v1202
			end
		end

		if bs_v1179.log_console:get() then
			bs_v1196 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
			bs_v1199 = bs_v706(bs_v1181, bs_v1189:to_hex())

			print_raw(("%s · %s %s for %s dmg ( left ~ %s )"):format(bs_v1196, bs_v1188, bs_v1199, tostring(bs_v1182), tostring(bs_v1183)))
		end

		return
	end

	if bs_v1186 then
		bs_v1193 = {
			{
				bs_v1189,
				bs_v1
			},
			{
				bs_v1187,
				" · "
			},
			{
				bs_v1187,
				bs_v1188
			},
			{
				bs_v1187,
				" "
			},
			{
				bs_v1189,
				bs_v1181
			},
			{
				bs_v1187,
				" for "
			},
			{
				bs_v1189,
				tostring(bs_v1182)
			},
			{
				bs_v1187,
				" dmg"
			}
		}

		if not bs_v1207 then
			table.insert(bs_v1193, {
				bs_v1187,
				" ( left ~ "
			})
			table.insert(bs_v1193, {
				bs_v1189,
				tostring(bs_v1183)
			})
			table.insert(bs_v1193, {
				bs_v1187,
				" )"
			})
		end

		bs_v26(bs_v1193)
	else
		bs_v1192 = {
			bs_v1188 .. " " .. bs_v1181 .. " for " .. tostring(bs_v1182) .. " dmg"
		}

		if not bs_v1207 then
			table.insert(bs_v1192, " ( left ~ " .. tostring(bs_v1183) .. " )")
		end

		bs_notify.new(bs_v1192, bs_v1189)
	end

	if bs_v1179.log_console:get() then
		bs_v1191 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
		bs_v1195 = bs_v706(bs_v1181, bs_v1189:to_hex())

		if bs_v1207 then
			print_raw(("%s · knifed %s for %s dmg"):format(bs_v1191, bs_v1195, tostring(bs_v1182)))
		else
			print_raw(("%s · %s %s for %s dmg ( left ~ %s )"):format(bs_v1191, bs_v1188, bs_v1195, tostring(bs_v1182), tostring(bs_v1183)))
		end
	end
end)
events.player_hurt(function(arg_408_0)
	local var_408_0 = bs_menu.info and bs_menu.info.notify

	if not var_408_0 or not var_408_0.log_enabled:get() then
		return
	end

	local var_408_1, var_408_2 = pcall(function()
		return var_408_0.log_hurt:get()
	end)

	if not var_408_1 or not var_408_2 then
		return
	end

	local var_408_3 = entity.get_local_player()

	if not var_408_3 then
		return
	end

	if entity.get(arg_408_0.userid, true) ~= var_408_3 then
		return
	end

	local var_408_4 = entity.get(arg_408_0.attacker, true)

	if not var_408_4 then
		return
	end

	local var_408_5, var_408_6 = pcall(function()
		return var_408_4:get_name()
	end)
	local var_408_7 = string.lower(string.sub(var_408_5 and var_408_6 or "unknown", 1, 15))
	local var_408_8 = bs_v695[arg_408_0.hitgroup] or "generic"
	local var_408_9 = arg_408_0.dmg_health
	local var_408_10 = arg_408_0.health
	local var_408_11, var_408_12 = pcall(function()
		return var_408_0.col_hurt:get()
	end)

	if not var_408_11 then
		var_408_12 = color(163, 166, 255, 255)
	end

	local var_408_13, var_408_14 = pcall(function()
		return var_408_0.log_mode:get()
	end)
	local var_408_15 = var_408_13 and var_408_14 == "text"
	local var_408_16 = color(180, 180, 185, 255)

	if var_408_15 then
		local var_408_17 = {
			{
				var_408_12,
				bs_v1
			},
			{
				var_408_16,
				" · hurt by "
			},
			{
				var_408_12,
				var_408_7
			},
			{
				var_408_16,
				" in "
			},
			{
				var_408_12,
				var_408_8
			},
			{
				var_408_16,
				" for "
			},
			{
				var_408_12,
				tostring(var_408_9)
			},
			{
				var_408_16,
				" dmg"
			}
		}

		if var_408_10 > 0 then
			table.insert(var_408_17, {
				var_408_16,
				" ( hp ~ "
			})
			table.insert(var_408_17, {
				var_408_12,
				tostring(var_408_10)
			})
			table.insert(var_408_17, {
				var_408_16,
				" )"
			})
		end

		bs_v26(var_408_17)
	end

	if var_408_0.log_console:get() then
		local var_408_18 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
		local var_408_19 = bs_v706(var_408_7, var_408_12:to_hex())

		print_raw(("%s · hurt by %s in %s for %s dmg%s"):format(var_408_18, var_408_19, var_408_8, tostring(var_408_9), var_408_10 > 0 and " ( hp ~ " .. tostring(var_408_10) .. " )" or ""))
	end
end)

bs_v69 = {}
bs_v72 = 0.35
bs_v87 = 3
bs_v102 = false
bs_v118 = false

function bs_v135()
	local var_413_0, var_413_1 = pcall(function()
		return entity.get_game_rules()
	end)

	if not var_413_0 or not var_413_1 then
		return false
	end

	local var_413_2, var_413_3 = pcall(function()
		return var_413_1.m_bFreezePeriod
	end)

	return var_413_2 and var_413_3 == true
end

function bs_v153()
	local var_416_0, var_416_1 = pcall(function()
		return entity.get_game_rules()
	end)

	if not var_416_0 or not var_416_1 then
		return nil
	end

	local var_416_2, var_416_3 = pcall(function()
		return var_416_1.m_bFreezePeriod
	end)

	if not var_416_2 or not var_416_3 then
		return nil
	end

	local var_416_4, var_416_5 = pcall(function()
		return var_416_1.m_flRestartRoundTime
	end)

	if not var_416_4 or not var_416_5 then
		return nil
	end

	return var_416_5 - globals.curtime
end

function bs_v177(arg_420_0)
	local var_420_0, var_420_1 = pcall(function()
		return arg_420_0:get_name()
	end)

	if var_420_0 and var_420_1 and var_420_1 ~= "" then
		return string.lower(string.sub(var_420_1, 1, 15))
	end

	return nil
end

events.item_purchase(function(arg_422_0)
	local var_422_0 = bs_menu.info and bs_menu.info.notify

	if not var_422_0 or not var_422_0.log_enabled:get() then
		return
	end

	local var_422_1, var_422_2 = pcall(function()
		return var_422_0.log_mode:get()
	end)

	if not var_422_1 or var_422_2 ~= "text" then
		return
	end

	local var_422_3 = entity.get_local_player()
	local var_422_4 = entity.get(arg_422_0.userid, true)

	if not var_422_4 or var_422_4 == var_422_3 then
		return
	end

	local var_422_5 = var_422_4:get_index()
	local var_422_6 = tostring(arg_422_0.weapon or "")
	local var_422_7 = var_422_6:gsub("^weapon_", ""):gsub("^item_", "")

	if var_422_7 == "assaultsuit" then
		var_422_7 = "kevlar+helmet"
	end

	if var_422_7 == "hegrenade" then
		var_422_7 = "nade"
	end

	if var_422_7 == "smokegrenade" then
		var_422_7 = "smoke"
	end

	if var_422_7 == "flashbang" then
		var_422_7 = "flash"
	end

	if var_422_7 == "incgrenade" then
		var_422_7 = "molly"
	end

	if var_422_7 == "molotov" then
		var_422_7 = "molly"
	end

	if var_422_7 == "" or var_422_7 == var_422_6 or var_422_7 == "unknown" then
		return
	end

	if not bs_v69[var_422_5] then
		bs_v69[var_422_5] = {
			buyer = var_422_4,
			name = bs_v177(var_422_4),
			items = {},
			time = globals.realtime
		}
	end

	table.insert(bs_v69[var_422_5].items, var_422_7)

	bs_v69[var_422_5].time = globals.realtime
end)

function bs_v200(arg_424_0)
	local var_424_0, var_424_1 = pcall(function()
		return arg_424_0.col_purchases:get()
	end)
	local var_424_2 = color(180, 180, 185, 255)
	local var_424_3 = var_424_0 and var_424_1 and var_424_1 or color(150, 195, 255, 255)

	for iter_424_0, iter_424_1 in pairs(bs_v69) do
		if not iter_424_1.name and iter_424_1.buyer then
			iter_424_1.name = bs_v177(iter_424_1.buyer)
		end

		local var_424_4 = iter_424_1.name or "unknown"

		if var_424_4 == "unknown" then
			bs_v69[iter_424_0] = nil
		else
			local var_424_5 = {}

			for iter_424_2, iter_424_3 in ipairs(iter_424_1.items) do
				if iter_424_3 ~= "unknown" then
					var_424_5[#var_424_5 + 1] = iter_424_3
				end
			end

			if #var_424_5 == 0 then
				bs_v69[iter_424_0] = nil
			else
				local var_424_6 = table.concat(var_424_5, ", ")
				local var_424_7 = {
					{
						var_424_3,
						bs_v1
					},
					{
						var_424_2,
						" · "
					},
					{
						var_424_3,
						var_424_4
					},
					{
						var_424_2,
						" bought "
					},
					{
						var_424_3,
						var_424_6
					}
				}

				bs_v26(var_424_7)

				if arg_424_0.log_console:get() then
					local var_424_8 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
					local var_424_9 = bs_v706(var_424_4, var_424_3:to_hex())

					print_raw(("%s · %s bought %s"):format(var_424_8, var_424_9, var_424_6))
				end

				bs_v69[iter_424_0] = nil
			end
		end
	end
end

events.render(function()
	local var_426_0 = bs_menu.info and bs_menu.info.notify

	if not var_426_0 or not var_426_0.log_enabled:get() then
		return
	end

	if not var_426_0.log_purchases:get() then
		return
	end

	local var_426_1, var_426_2 = pcall(function()
		return var_426_0.log_mode:get()
	end)

	if not var_426_1 or var_426_2 ~= "text" then
		return
	end

	local var_426_3 = bs_v135()

	if next(bs_v69) == nil then
		if not var_426_3 then
			bs_v118 = false
		end

		bs_v102 = var_426_3

		return
	end

	if bs_v102 and not var_426_3 then
		bs_v118 = false

		bs_v200(var_426_0)
	elseif var_426_3 and not bs_v118 then
		local var_426_4 = bs_v153()

		if var_426_4 and var_426_4 <= bs_v87 then
			bs_v118 = true

			bs_v200(var_426_0)
		end
	elseif not var_426_3 then
		local var_426_5 = globals.realtime
		local var_426_6 = false

		for iter_426_0, iter_426_1 in pairs(bs_v69) do
			if var_426_5 - iter_426_1.time >= bs_v72 then
				var_426_6 = true

				break
			end
		end

		if var_426_6 then
			bs_v200(var_426_0)
		end
	end

	bs_v102 = var_426_3
end)
events.dormant_hit(function(arg_428_0)
	bs_v1210 = bs_menu.info and bs_menu.info.notify

	if not bs_v1210 or not bs_v1210.log_enabled:get() then
		return
	end

	bs_v1221, bs_v1233 = pcall(function()
		return bs_v1210.log_dormant:get()
	end)

	if not bs_v1221 or not bs_v1233 then
		return
	end

	bs_v1234, bs_v1235 = pcall(function()
		return bs_config.rage.main.dormant_aimbot:get()
	end)

	if not bs_v1234 or not bs_v1235 then
		return
	end

	bs_v1236 = entity.get_local_player()

	if not bs_v1236 or not bs_v1236:is_alive() then
		return
	end

	bs_v1237 = entity.get(arg_428_0.userid, true)

	if not bs_v1237 then
		return
	end

	bs_v1238, bs_v1239 = pcall(function()
		return bs_v1237:get_name()
	end)
	bs_v1211 = string.lower(string.sub(bs_v1238 and bs_v1239 or "unknown", 1, 15))
	bs_v1212 = bs_v695[arg_428_0.hitgroup] or "generic"
	bs_v1213 = string.lower(tostring(arg_428_0.aim_hitbox or ""))
	bs_v1214 = bs_v1212 == bs_v1213
	bs_v1215 = math.floor((arg_428_0.accuracy or 0) * 100 + 0.5)
	bs_v1216 = arg_428_0.dmg_health
	bs_v1217 = arg_428_0.health
	bs_v1218, bs_v1219 = pcall(function()
		return bs_v1210.log_mode:get()
	end)
	bs_v1220 = bs_v1218 and bs_v1219 == "text"
	bs_v1222 = color(180, 180, 185, 255)
	bs_v1223, bs_v1224 = pcall(function()
		return bs_v1210.col_dormant_hit:get()
	end)

	if not bs_v1223 then
		bs_v1224 = color(106, 255, 84, 255)
	end

	bs_v1225, bs_v1226 = pcall(function()
		return bs_v1210.col_mismatch:get()
	end)

	if not bs_v1225 then
		bs_v1226 = color(255, 159, 94, 255)
	end

	bs_v1227 = not bs_v1214 and bs_v1226 or bs_v1224

	if bs_v1220 then
		bs_v1230 = {
			{
				bs_v1227,
				bs_v1
			},
			{
				bs_v1222,
				" · dormant hit "
			},
			{
				bs_v1227,
				bs_v1211
			},
			{
				bs_v1222,
				"'s "
			},
			{
				bs_v1227,
				bs_v1212
			}
		}

		if not bs_v1214 then
			table.insert(bs_v1230, {
				bs_v1222,
				"["
			})
			table.insert(bs_v1230, {
				bs_v1224,
				bs_v1213
			})
			table.insert(bs_v1230, {
				bs_v1222,
				"]"
			})
		end

		table.insert(bs_v1230, {
			bs_v1222,
			" for "
		})
		table.insert(bs_v1230, {
			bs_v1227,
			tostring(bs_v1216)
		})
		table.insert(bs_v1230, {
			bs_v1222,
			" dmg ( ac ~ "
		})
		table.insert(bs_v1230, {
			bs_v1227,
			tostring(bs_v1215) .. "%"
		})

		if bs_v1217 > 0 then
			table.insert(bs_v1230, {
				bs_v1222,
				" / hp ~ "
			})
			table.insert(bs_v1230, {
				bs_v1227,
				tostring(bs_v1217)
			})
		end

		table.insert(bs_v1230, {
			bs_v1222,
			" )"
		})
		bs_v26(bs_v1230)
	else
		bs_v1229 = {
			"dormant hit ",
			bs_v1211,
			"'s ",
			bs_v1212,
			" for ",
			bs_v1216,
			" dmg"
		}

		if not bs_v1214 then
			table.insert(bs_v1229, " [" .. bs_v1213 .. "]")
		end

		bs_notify.new(bs_v1229, bs_v1227)
	end

	if bs_v1210.log_console:get() then
		bs_v1228 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
		bs_v1231 = bs_v706(bs_v1211, bs_v1227:to_hex())
		bs_v1232 = bs_v1214 and "" or " [aimed: " .. bs_v1213 .. "]"

		print_raw(("%s · dormant hit %s's %s%s for %s dmg ( ac ~ %s%% / hp ~ %s )"):format(bs_v1228, bs_v1231, bs_v1212, bs_v1232, tostring(bs_v1216), tostring(bs_v1215), tostring(bs_v1217)))
	end
end)
events.dormant_miss(function(arg_435_0)
	local var_435_0 = bs_menu.info and bs_menu.info.notify

	if not var_435_0 or not var_435_0.log_enabled:get() then
		return
	end

	local var_435_1, var_435_2 = pcall(function()
		return var_435_0.log_dormant:get()
	end)

	if not var_435_1 or not var_435_2 then
		return
	end

	local var_435_3, var_435_4 = pcall(function()
		return bs_config.rage.main.dormant_aimbot:get()
	end)

	if not var_435_3 or not var_435_4 then
		return
	end

	local var_435_5 = entity.get_local_player()

	if not var_435_5 or not var_435_5:is_alive() then
		return
	end

	local var_435_6 = entity.get(arg_435_0.userid, true)

	if not var_435_6 then
		return
	end

	local var_435_7, var_435_8 = pcall(function()
		return var_435_6:get_name()
	end)
	local var_435_9 = string.lower(string.sub(var_435_7 and var_435_8 or "unknown", 1, 15))
	local var_435_10 = string.lower(tostring(arg_435_0.aim_hitbox or "unknown"))
	local var_435_11 = string.lower(tostring(arg_435_0.aim_point or "unknown"))
	local var_435_12 = math.floor((arg_435_0.accuracy or 0) * 100 + 0.5)
	local var_435_13, var_435_14 = pcall(function()
		return var_435_0.log_mode:get()
	end)
	local var_435_15 = var_435_13 and var_435_14 == "text"
	local var_435_16 = color(180, 180, 185, 255)
	local var_435_17, var_435_18 = pcall(function()
		return var_435_0.col_dormant_miss:get()
	end)

	if not var_435_17 then
		var_435_18 = color(255, 115, 115, 255)
	end

	if var_435_15 then
		local var_435_19 = {
			{
				var_435_18,
				bs_v1
			},
			{
				var_435_16,
				" · dormant miss "
			},
			{
				var_435_18,
				var_435_9
			},
			{
				var_435_16,
				"'s "
			},
			{
				var_435_18,
				var_435_10
			},
			{
				var_435_16,
				" ["
			},
			{
				var_435_18,
				var_435_11
			},
			{
				var_435_16,
				"] ( ac ~ "
			},
			{
				var_435_18,
				tostring(var_435_12) .. "%"
			},
			{
				var_435_16,
				" )"
			}
		}

		bs_v26(var_435_19)
	else
		bs_notify.new({
			"dormant miss ",
			var_435_9,
			"'s ",
			var_435_10,
			" [",
			var_435_11,
			"]"
		}, var_435_18)
	end

	if var_435_0.log_console:get() then
		local var_435_20 = bs_v706(bs_v1, ui.get_style()["Link Active"]:to_hex())
		local var_435_21 = bs_v706(var_435_9, var_435_18:to_hex())

		print_raw(("%s · dormant miss %s's %s [%s] ( ac ~ %s%% )"):format(var_435_20, var_435_21, var_435_10, var_435_11, tostring(var_435_12)))
	end
end)
pcall(ffi.cdef, "void* AddFontMemResourceEx(void* pFileView, unsigned long cjSize, void* pvResrved, unsigned long* pNumFonts);")

bs_v694 = nil

pcall(function()
	bs_v694 = ffi.load("gdi32")
end)

bs_v705 = {}
bs_v716 = render.load_font("Verdana", vector(0, 10, 3), "ab")
bs_v730 = 2
bs_v743 = render.load_font("Verdana", 10, "ab")
bs_v753 = render.load_font("Verdana", 14, "ab")
bs_v764 = render.load_font("Verdana", 14, "ab")
bs_v10 = "nl\\bluesense\\Inter_28pt-Bold.ttf"
bs_v25 = "https://cdn.jsdelivr.net/gh/yirahvh-spec/bluesense@main/Inter_28pt-Bold.ttf"
bs_v38 = "Inter 28pt"

function bs_v53(arg_442_0)
	if not arg_442_0 or #arg_442_0 < 4096 then
		return false
	end

	local var_442_0, var_442_1, var_442_2, var_442_3 = arg_442_0:byte(1, 4)
	local var_442_4 = var_442_0 == 0 and var_442_1 == 1 and var_442_2 == 0 and var_442_3 == 0 or var_442_0 == 116 and var_442_1 == 114 and var_442_2 == 117 and var_442_3 == 101
	local var_442_5 = var_442_0 == 79 and var_442_1 == 84 and var_442_2 == 84 and var_442_3 == 79

	return var_442_4 or var_442_5
end

bs_v68 = bs_v743

function bs_v83()
	local var_443_0, var_443_1 = pcall(render.load_font, bs_v10, 12, "ab")

	if var_443_0 and var_443_1 then
		bs_v68 = var_443_1
	end

	local var_443_2, var_443_3 = pcall(render.load_font, bs_v10, 15, "ab")

	if var_443_2 and var_443_3 then
		bs_v764 = var_443_3
	end

	local var_443_4, var_443_5 = pcall(render.load_font, bs_v10, 22, "ab")

	if var_443_4 and var_443_5 then
		bs_ui_elements2 = var_443_5
	end

	local var_443_6, var_443_7 = pcall(render.load_font, bs_v10, 10, "ab")

	if var_443_6 and var_443_7 then
		bs_font_10 = var_443_7
	end

	local var_443_8, var_443_9 = pcall(render.load_font, bs_v10, 14, "ab")

	if var_443_8 and var_443_9 then
		bs_font_14 = var_443_9
	end

	local var_443_10, var_443_11 = pcall(render.load_font, bs_v10, 11, "ab")

	if var_443_10 and var_443_11 then
		bs_font_11 = var_443_11
	end

	local var_443_12, var_443_13 = pcall(render.load_font, bs_v10, 12, "ab")

	if var_443_12 and var_443_13 then
		bs_font_13 = var_443_13
	end

	local var_443_14, var_443_15 = pcall(render.load_font, bs_v10, 11, "ab")

	if var_443_14 and var_443_15 then
		bs_font_12b = var_443_15
	end
end

bs_v86 = files.read(bs_v10, true)

if bs_v53(bs_v86) then
	bs_v83()
else
	-- Custom UI font (Inter_28pt-Bold.ttf) is cosmetic only; the Verdana
	-- fonts loaded above are the fallback. Attempt the download once and stay
	-- silent on failure so the console is never spammed. Only reload if the
	-- write actually produced a valid font file, otherwise we would loop
	-- reloading forever.
	network.get(bs_v25, nil, function(arg_444_0)
		if not bs_v53(arg_444_0) then
			return
		end

		pcall(files.write, bs_v10, arg_444_0, true)

		if bs_v53(files.read(bs_v10, true)) then
			bs_logger:message("font downloaded! reloading script...")
			common.reload_script()
		end
	end)
end

bs_v114 = 0
bs_v117 = 0
bs_v134 = 0
bs_v152 = 0
bs_v176 = 0
bs_v199 = 0
bs_v219 = bs_position_dragger:new("wm_modern", vector(bs_screen_size.x * 0.5, bs_screen_size.y - 28), "xy")
bs_v239 = "✦"
bs_v258 = render.load_font("Verdana", 13, "ab")
bs_v273 = render.load_font("Verdana", 22, "ab")
bs_v287 = "nl\\bluesense\\bluesense_E_logo.png"
bs_v301 = "https://cdn.jsdelivr.net/gh/yirahvh-spec/bluesense@main/bluesense_E_logo.png"
bs_v325 = nil
bs_v338 = 120
bs_v350 = 92
bs_v364 = 34
bs_v372 = 15
bs_v382 = bs_position_dragger:new("wm_logo_w", vector(bs_screen_size.x - 80, 80), "xy")

;(function()
	local var_445_0 = files.read(bs_v287, true)

	if var_445_0 and #var_445_0 > 64 then
		local var_445_1, var_445_2 = pcall(render.load_image_from_file, bs_v287, vector(bs_v338, bs_v350))

		if var_445_1 and var_445_2 then
			bs_v325 = var_445_2

			return
		end
	end

	network.get(bs_v301, nil, function(arg_446_0)
		if not arg_446_0 or #arg_446_0 < 64 then
			return
		end

		pcall(files.write, bs_v287, arg_446_0, true)

		local var_446_0, var_446_1 = pcall(render.load_image_from_file, bs_v287, vector(bs_v338, bs_v350))

		if var_446_0 and var_446_1 then
			bs_v325 = var_446_1
		end
	end)
end)()

function bs_v399(arg_447_0)
	if arg_447_0 and arg_447_0.font and arg_447_0.font:get() == "pixel" then
		return bs_v730
	end

	return bs_v716
end

function bs_v407(arg_448_0)
	if arg_448_0 and arg_448_0.font and arg_448_0.font:get() == "pixel" then
		return "E L Y S I A N"
	end

	return (arg_448_0 and arg_448_0.name_case and arg_448_0.name_case:get()) == "lowercase" and "bluesense" or "bluesense"
end

function bs_v415(arg_449_0, arg_449_1, arg_449_2)
	arg_449_2 = math.max(0, math.min(1, arg_449_2))

	return color(math.floor(arg_449_0.r + (arg_449_1.r - arg_449_0.r) * arg_449_2), math.floor(arg_449_0.g + (arg_449_1.g - arg_449_0.g) * arg_449_2), math.floor(arg_449_0.b + (arg_449_1.b - arg_449_0.b) * arg_449_2), math.floor(arg_449_0.a + (arg_449_1.a - arg_449_0.a) * arg_449_2))
end

function bs_v422(arg_450_0, arg_450_1, arg_450_2, arg_450_3, arg_450_4, arg_450_5, arg_450_6, arg_450_7, arg_450_8)
	local var_450_0 = math.floor(arg_450_8 * 0.22)

	if var_450_0 > 1 then
		render.rect(vector(arg_450_0 - 2, arg_450_1), vector(arg_450_2 + 2, arg_450_3 + 4), color(0, 0, 0, var_450_0), arg_450_4 + 2)
	end

	if arg_450_5 then
		render.blur(vector(arg_450_0, arg_450_1), vector(arg_450_2, arg_450_3), 6, 0.85, arg_450_4)
		render.blur(vector(arg_450_0, arg_450_1), vector(arg_450_2, arg_450_3), 3, 0.55, arg_450_4)
		render.blur(vector(arg_450_0, arg_450_1), vector(arg_450_2, arg_450_3), 1, 0.25, arg_450_4)
	end

	render.rect(vector(arg_450_0, arg_450_1), vector(arg_450_2, arg_450_3), color(arg_450_6.r, arg_450_6.g, arg_450_6.b, arg_450_6.a), arg_450_4)

	local var_450_1 = arg_450_3 - arg_450_1

	render.rect(vector(arg_450_0 + 1, arg_450_1 + 1), vector(arg_450_2 - 1, arg_450_1 + 1 + math.floor(var_450_1 * 0.44)), color(255, 255, 255, 22), arg_450_4)
	render.rect_outline(vector(arg_450_0, arg_450_1), vector(arg_450_2, arg_450_3), color(arg_450_7.r, arg_450_7.g, arg_450_7.b, arg_450_7.a), 1, arg_450_4)
end

function bs_v427(arg_451_0, arg_451_1, arg_451_2)
	bs_v1270 = arg_451_0.m_col_accent:get()
	bs_v1280 = arg_451_0.m_col_text:get()
	bs_v1291 = arg_451_0.m_show_nick:get()
	bs_v1319 = arg_451_0.m_show_fps:get()
	bs_v1332 = arg_451_0.m_show_ping:get()
	bs_v1342 = bs_v68 and bs_v68 ~= 0 and bs_v68 ~= 1 and bs_v68 or bs_v743

	if arg_451_0.m_font and (function()
		local var_452_0, var_452_1 = pcall(function()
			return arg_451_0.m_font:get()
		end)

		return var_452_0 and var_452_1 == "verdana"
	end)() then
		bs_v1342 = bs_v743
	end

	bs_v1367 = arg_451_0.m_col_bg and arg_451_0.m_col_bg:get() or color(15, 15, 18, 210)
	bs_v1253, bs_v1251 = arg_451_0.m_col_border and arg_451_0.m_col_border:get() or color(255, 255, 255, 40), bs_v1367
	bs_v1254 = bs_blur_func()
	bs_v1255 = bs_v1270.r
	bs_v1256 = bs_v1270.g
	bs_v1257 = bs_v1270.b
	bs_v1258 = bs_v1270.a
	bs_v1259 = bs_v1280.r
	bs_v1260 = bs_v1280.g
	bs_v1261 = bs_v1280.b
	bs_v1262 = bs_v1280.a
	bs_v1263 = arg_451_0.m_shimmer_en and arg_451_0.m_shimmer_en:get() or false
	bs_v1264 = bs_v1263 and arg_451_0.m_col_shimmer and arg_451_0.m_col_shimmer:get() or nil
	bs_v1265 = bs_v1264 and bs_v1264.r or bs_v1259
	bs_v1266 = bs_v1264 and bs_v1264.g or bs_v1260
	bs_v1267 = bs_v1264 and bs_v1264.b or bs_v1261
	bs_v1268 = bs_v1264 and bs_v1264.a or bs_v1262
	bs_v1269 = (arg_451_0.m_logo_mode and arg_451_0.m_logo_mode:get() or "logo") == "text"
	bs_v1271 = (arg_451_0.m_text_case and arg_451_0.m_text_case:get() or "lowercase") == "uppercase" and "bluesense" or "bluesense"
	bs_v1272 = 3
	bs_v1273 = 9
	bs_v1274 = bs_v1269 and 18 or 13
	bs_v1275 = 40
	bs_v1276 = 13
	bs_v1277 = 9
	bs_v1278 = 1
	bs_v1279 = arg_451_0.m_font and (function()
		local var_454_0, var_454_1 = pcall(function()
			return arg_451_0.m_font:get()
		end)

		return var_454_0 and var_454_1 == "verdana"
	end)()
	bs_v1281 = bs_v1269 and (bs_v1279 and bs_v753 or bs_v764 and bs_v764 ~= 0 and bs_v764 ~= 1 and bs_v764 or bs_v743) or bs_v753
	bs_v1282 = render.measure_text(bs_v1281, nil, bs_v1271)
	bs_v1283 = 2
	bs_v1284 = bs_v1282.x + bs_v1283 * (#bs_v1271 - 1)
	bs_v1285 = nil

	if bs_v1269 then
		bs_v1285 = bs_v1284 + bs_v1274 * 2
	else
		bs_v1285 = 24 + bs_v1274 * 2
	end

	bs_v1286 = render.measure_text(bs_v1342, nil, "A").y
	bs_v1287 = bs_v1286 + 18
	bs_v1288 = ""
	bs_v1289 = "·"
	bs_v1290 = 5
	bs_v1292 = {}

	if bs_v1291 then
		bs_v1296, bs_v1300 = pcall(function()
			return common.get_username()
		end)
		bs_v1304 = bs_v1296 and bs_v1300 and bs_v1300 ~= "" and bs_v1300 or "player"
		bs_v1310 = bs_v1304 == "inmyhell" and "meduza" or bs_v1304
		bs_v1312 = render.measure_text(bs_v1342, nil, bs_v1310)
		bs_v1314 = render.measure_text(bs_v258, nil, bs_v1288)
		bs_v1316 = render.measure_text(bs_v1342, nil, bs_v1289)
		bs_v1318 = bs_v1314.x + bs_v1290 + bs_v1316.x + bs_v1290
		bs_v1292[#bs_v1292 + 1] = {
			text = bs_v1310,
			w = bs_v1318 + bs_v1312.x,
			nick_only_w = bs_v1312.x,
			prefix_icon = bs_v1288,
			prefix_icon_w = bs_v1314.x,
			dot_sep = bs_v1289,
			dot_sep_w = bs_v1316.x,
			prefix_w = bs_v1318,
			icon_gap = bs_v1290
		}
	end

	if bs_v1319 then
		bs_v1295 = 1 / math.max(globals.frametime, 0.0001)
		bs_v152 = bs_v152 + (bs_v1295 - bs_v152) * math.min(1, arg_451_1 * 15)

		if bs_v176 == 0 then
			bs_v176 = bs_v152
		end

		bs_v176 = bs_v176 + (bs_v152 - bs_v176) * math.min(1, arg_451_1 * 0.6)
		bs_v1299 = math.floor(bs_v176 + 0.5) .. "fps"
		bs_v1303 = render.measure_text(bs_v1342, nil, "000fps").x
		bs_v1292[#bs_v1292 + 1] = {
			right_align = true,
			text = bs_v1299,
			w = bs_v1303
		}
	end

	if bs_v1332 then
		bs_v1294 = 0
		bs_v1298, bs_v1302 = pcall(function()
			return utils.net_channel()
		end)

		if bs_v1298 and bs_v1302 then
			bs_v1306, bs_v1309 = pcall(function()
				if type(bs_v1302.latency) == "table" then
					return (bs_v1302.latency[1] or 0) * 1000
				end

				return 0
			end)

			if bs_v1306 and bs_v1309 then
				bs_v1294 = math.floor(bs_v1309 + 0.5)
			end
		end

		bs_v134 = bs_v134 + (bs_v1294 - bs_v134) * math.min(1, arg_451_1 * 6)
		bs_v1308 = math.floor(bs_v134 + 0.5) .. "ms"
		bs_v1292[#bs_v1292 + 1] = {
			text = bs_v1308,
			w = render.measure_text(bs_v1342, nil, bs_v1308).x
		}
	end

	bs_v1293 = 0

	for iter_451_0, iter_451_1 in ipairs(bs_v1292) do
		if iter_451_0 > 1 then
			bs_v1293 = bs_v1293 + bs_v1277 + bs_v1278 + bs_v1277
		end

		bs_v1293 = bs_v1293 + iter_451_1.w
	end

	bs_v1297 = #bs_v1292 > 0 and bs_v1276 + bs_v1293 + bs_v1276 or 0
	bs_v1301 = math.min(1, arg_451_1 * 20)
	bs_v199 = bs_v199 + (bs_v1297 - bs_v199) * bs_v1301
	bs_v1305 = math.floor(bs_v199 + 0.5)
	bs_v1307 = bs_v1305 > 8
	bs_v1311 = bs_v1285 + (bs_v1307 and bs_v1272 + bs_v1305 or 0)
	bs_v1313 = math.max(bs_v1275, bs_v1287)
	bs_v1315 = ui.get_alpha() > 0
	bs_v1317 = false

	if bs_v1315 and bs_tab_dummy then
		bs_v1321, bs_v1323 = pcall(function()
			return bs_tab_dummy:get()
		end)
		bs_v1317 = bs_v1321 and bs_v1323 == 2
	end

	if bs_v1317 then
		bs_v219:update(vector(bs_v1311, bs_v1313))
	end

	bs_v1320 = math.max(bs_v219.hover_anim, bs_v219.grab_anim)

	if bs_v1320 > 0.005 then
		bs_draw_panel_bg(bs_v219.position, vector(bs_v1311, bs_v1313), bs_v1320)
	end

	bs_v1322 = math.floor(bs_v219.position.x)
	bs_v1324 = math.floor(bs_v219.position.y)
	bs_v1325 = bs_v1322 - math.floor(bs_v1311 * 0.5)
	bs_v114 = bs_v114 + arg_451_1
	bs_v117 = bs_v117 + arg_451_1
	bs_v1326 = bs_v114 * 0.6 % 1.3 - 0.15
	bs_v1327 = bs_v1325
	bs_v1328 = bs_v1324 - math.floor(bs_v1275 * 0.5)
	bs_v1329 = bs_v1327 + bs_v1285
	bs_v1330 = bs_v1328 + bs_v1275
	bs_v1331 = bs_v1327 + math.floor(bs_v1285 * 0.5)
	bs_v1333 = bs_v1328 + math.floor(bs_v1275 * 0.5)
	bs_v1334 = bs_v1331 - math.floor(bs_v1284 * 0.5)
	bs_v1335 = bs_v1325 + bs_v1285 + bs_v1272 + math.floor((bs_v1305 - bs_v1293) * 0.5)
	bs_v1336 = bs_v1307 and bs_v1335 + bs_v1293 or bs_v1334 + bs_v1284
	bs_v1337 = math.max(bs_v1336 - bs_v1334, 1)

	bs_v422(bs_v1327, bs_v1328, bs_v1329, bs_v1330, bs_v1273, bs_v1254, bs_v1251, bs_v1253, 210)

	bs_v1338 = (math.sin(bs_v117 * 1.4) + 1) * 0.5
	bs_v1339 = bs_v1327
	bs_v1340 = bs_v1307 and bs_v1329 + bs_v1272 + bs_v1305 or bs_v1329
	bs_v1341 = math.max(bs_v1340 - bs_v1339, 1)

	if not bs_v1269 then
		bs_v1345 = render.measure_text(bs_v273, nil, bs_v239)
		bs_v1348 = bs_v1331 - math.floor(bs_v1345.x * 0.5)
		bs_v1351 = bs_v1333 - math.floor(bs_v1345.y * 0.5) - 2
		bs_v1354 = bs_v1338 * bs_v1338
		bs_v1357 = math.abs((bs_v1331 - bs_v1339) / bs_v1341 - bs_v1326)
		bs_v1360 = math.max(0, 1 - bs_v1357 / 0.22)
		bs_v1359 = bs_v1360 * bs_v1360 * bs_v1360
		bs_v1362 = bs_v1263 and math.min(1, bs_v1354 * 0.5 + bs_v1359 * 0.8) or 0.28 + bs_v1338 * 0.72
		bs_v1364 = bs_v1263 and bs_v1265 or bs_v1255
		bs_v1365 = bs_v1263 and bs_v1266 or bs_v1256
		bs_v1366 = bs_v1263 and bs_v1267 or bs_v1257
		bs_v1368 = bs_v1263 and bs_v1268 or bs_v1258
		bs_v1369 = {
			{
				4,
				bs_v1362 * 0.05
			},
			{
				2,
				bs_v1362 * 0.14
			},
			{
				1,
				bs_v1362 * 0.32
			}
		}

		for iter_451_2, iter_451_3 in ipairs(bs_v1369) do
			bs_v1388 = iter_451_3[1]
			bs_v1390 = iter_451_3[2]
			bs_v1392 = math.floor(bs_v1368 * bs_v1390)

			if bs_v1392 > 1 then
				bs_v1241 = color(bs_v1364, bs_v1365, bs_v1366, bs_v1392)

				for iter_451_4, iter_451_5 in ipairs({
					{
						-bs_v1388,
						0
					},
					{
						bs_v1388,
						0
					},
					{
						0,
						-bs_v1388
					},
					{
						0,
						bs_v1388
					}
				}) do
					render.text(bs_v273, vector(bs_v1348 + iter_451_5[1], bs_v1351 + iter_451_5[2]), bs_v1241, nil, bs_v239)
				end
			end
		end

		bs_v1371 = math.floor(bs_v1258 * (0.88 + bs_v1362 * 0.12))

		render.text(bs_v273, vector(bs_v1348, bs_v1351), color(bs_v1255, bs_v1256, bs_v1257, bs_v1371), nil, bs_v239)
	else
		bs_v1344 = bs_v1282.y
		bs_v1347 = bs_v1334
		bs_v1350 = bs_v1333 - math.floor(bs_v1344 * 0.5) - 1
		bs_v1353 = {}
		bs_v1356 = {}

		for iter_451_6 = 1, #bs_v1271 do
			bs_v1353[iter_451_6] = bs_v1271:sub(iter_451_6, iter_451_6)
			bs_v1356[iter_451_6] = render.measure_text(bs_v1281, nil, bs_v1353[iter_451_6]).x
		end

		bs_v1358 = bs_v1347

		for iter_451_7, iter_451_8 in ipairs(bs_v1353) do
			bs_v1370 = (bs_v1358 + bs_v1356[iter_451_7] * 0.5 - bs_v1334) / bs_v1337
			bs_v1374 = math.abs(bs_v1370 - bs_v1326)
			bs_v1378 = math.max(0, 1 - bs_v1374 / 0.12)
			bs_v1377 = bs_v1378 * bs_v1378 * bs_v1378
			bs_v1382 = bs_v1263 and bs_v1377 or 0
			bs_v1385 = math.min(255, math.floor(bs_v1255 + (bs_v1265 - bs_v1255) * bs_v1382 * 0.85))
			bs_v1387 = math.min(255, math.floor(bs_v1256 + (bs_v1266 - bs_v1256) * bs_v1382 * 0.85))
			bs_v1389 = math.min(255, math.floor(bs_v1257 + (bs_v1267 - bs_v1257) * bs_v1382 * 0.85))
			bs_v1391 = math.floor(bs_v1258 * (0.92 + bs_v1338 * 0.08))
			bs_v1240 = bs_v1263 and math.floor(bs_v1268 * bs_v1377 * 0.28) or 0

			if bs_v1240 > 2 then
				render.text(bs_v1281, vector(bs_v1358 + 1, bs_v1350 + 1), color(bs_v1265, bs_v1266, bs_v1267, bs_v1240), nil, iter_451_8)
				render.text(bs_v1281, vector(bs_v1358 - 1, bs_v1350 + 1), color(bs_v1265, bs_v1266, bs_v1267, math.floor(bs_v1240 * 0.5)), nil, iter_451_8)
			end

			render.text(bs_v1281, vector(bs_v1358, bs_v1350), color(bs_v1385, bs_v1387, bs_v1389, bs_v1391), nil, iter_451_8)

			bs_v1358 = bs_v1358 + bs_v1356[iter_451_7] + (iter_451_7 < #bs_v1353 and bs_v1283 or 0)
		end
	end

	if bs_v1307 then
		bs_v1343 = bs_v1325 + bs_v1285 + bs_v1272
		bs_v1346 = bs_v1324 - math.floor(bs_v1287 * 0.5)
		bs_v1349 = bs_v1343 + bs_v1305
		bs_v1352 = bs_v1346 + bs_v1287

		bs_v422(bs_v1343, bs_v1346, bs_v1349, bs_v1352, bs_v1273, bs_v1254, bs_v1251, bs_v1253, 210)

		bs_v1355 = bs_v1346 + math.floor(bs_v1287 * 0.5)
		bs_v1361 = bs_v1335

		function bs_v1363(arg_460_0, arg_460_1, arg_460_2)
			local var_460_0 = arg_460_2 - arg_460_1
			local var_460_1 = math.floor(bs_v1253.r * 0.55 + 12.75)
			local var_460_2 = math.floor(bs_v1253.g * 0.55 + 12.75)
			local var_460_3 = math.floor(bs_v1253.b * 0.55 + 12.75)
			local var_460_4 = math.max(bs_v1253.a, 55)

			for iter_460_0 = arg_460_1, arg_460_2 do
				local var_460_5 = (iter_460_0 - arg_460_1) / math.max(var_460_0, 1)
				local var_460_6 = math.sin(var_460_5 * math.pi)
				local var_460_7 = var_460_6 * var_460_6
				local var_460_8 = math.floor(var_460_4 * var_460_7)

				if var_460_8 > 1 then
					render.rect(vector(arg_460_0, iter_460_0), vector(arg_460_0 + bs_v1278, iter_460_0 + 1), color(var_460_1, var_460_2, var_460_3, var_460_8))
				end
			end
		end

		for iter_451_9, iter_451_10 in ipairs(bs_v1292) do
			if iter_451_9 > 1 then
				bs_v1361 = bs_v1361 + bs_v1277
				bs_v1373 = bs_v1355 - math.floor(bs_v1286 * 0.5) - 3
				bs_v1376 = bs_v1355 + math.floor(bs_v1286 * 0.5) + 3

				bs_v1363(bs_v1361, bs_v1373, bs_v1376)

				bs_v1361 = bs_v1361 + bs_v1278 + bs_v1277
			end

			bs_v1372 = bs_v1355 - math.floor(bs_v1286 * 0.5)
			bs_v1375 = bs_v1361

			if iter_451_10.prefix_icon then
				bs_v1381 = render.measure_text(bs_v258, nil, iter_451_10.prefix_icon).y
				bs_v1384 = bs_v1355 - math.floor(bs_v1381 * 0.5)

				render.text(bs_v258, vector(bs_v1361, bs_v1384), color(bs_v1259, bs_v1260, bs_v1261, math.floor(bs_v1262 * 0.85)), nil, iter_451_10.prefix_icon)

				bs_v1386 = bs_v1361 + iter_451_10.prefix_icon_w + iter_451_10.icon_gap

				render.text(bs_v1342, vector(bs_v1386, bs_v1372), color(bs_v1259, bs_v1260, bs_v1261, math.floor(bs_v1262 * 0.55)), nil, iter_451_10.dot_sep)

				bs_v1375 = bs_v1361 + iter_451_10.prefix_w
			else
				bs_v1380 = render.measure_text(bs_v1342, nil, iter_451_10.text).x

				if iter_451_10.right_align then
					bs_v1375 = bs_v1361 + iter_451_10.w - bs_v1380
				else
					bs_v1375 = bs_v1361 + math.floor((iter_451_10.w - bs_v1380) * 0.5)
				end
			end

			bs_v1379 = {}

			for iter_451_11 = 1, #iter_451_10.text do
				bs_v1379[iter_451_11] = iter_451_10.text:sub(iter_451_11, iter_451_11)
			end

			bs_v1383 = bs_v1375

			for iter_451_12, iter_451_13 in ipairs(bs_v1379) do
				bs_v1242 = render.measure_text(bs_v1342, nil, iter_451_13)
				bs_v1243 = (bs_v1383 + bs_v1242.x * 0.5 - bs_v1339) / bs_v1341
				bs_v1244 = math.abs(bs_v1243 - bs_v1326)
				bs_v1246 = math.max(0, 1 - bs_v1244 / 0.15)
				bs_v1245 = bs_v1246 * bs_v1246 * bs_v1246
				bs_v1247 = bs_v1263 and bs_v1245 or 0
				bs_v1248 = math.min(255, math.floor(bs_v1259 + (bs_v1265 - bs_v1259) * bs_v1247 * 0.92))
				bs_v1249 = math.min(255, math.floor(bs_v1260 + (bs_v1266 - bs_v1260) * bs_v1247 * 0.92))
				bs_v1250 = math.min(255, math.floor(bs_v1261 + (bs_v1267 - bs_v1261) * bs_v1247 * 0.92))
				bs_v1252 = bs_v1263 and math.floor(bs_v1268 * bs_v1245 * 0.3) or 0

				if bs_v1252 > 2 then
					render.text(bs_v1342, vector(bs_v1383 + 1, bs_v1372), color(bs_v1265, bs_v1266, bs_v1267, bs_v1252), nil, iter_451_13)
					render.text(bs_v1342, vector(bs_v1383 - 1, bs_v1372), color(bs_v1265, bs_v1266, bs_v1267, math.floor(bs_v1252 * 0.55)), nil, iter_451_13)
					render.text(bs_v1342, vector(bs_v1383, bs_v1372 - 1), color(bs_v1265, bs_v1266, bs_v1267, math.floor(bs_v1252 * 0.4)), nil, iter_451_13)
				end

				render.text(bs_v1342, vector(bs_v1383, bs_v1372), color(bs_v1248, bs_v1249, bs_v1250, bs_v1262), nil, iter_451_13)

				bs_v1383 = bs_v1383 + bs_v1242.x
			end

			bs_v1361 = bs_v1361 + iter_451_10.w
		end
	end
end

events.render(function()
	bs_v1393 = bs_menu.info.watermark

	if not bs_v1393 then
		return
	end

	bs_v1394 = entity.get_local_player()

	if bs_v1394 == nil then
		return
	end

	bs_v1408 = math.max(0.001, math.min(globals.frametime, 0.05))

	if bs_v1393.style and bs_v1393.style:get() == "modern" then
		bs_v427(bs_v1393, bs_v1408, bs_v1394)

		return
	end

	if bs_v1393.style and bs_v1393.style:get() == "logo" then
		if bs_v325 then
			bs_v1415 = bs_v338 - bs_v364 * 2
			bs_v1428 = bs_v350 - bs_v372 * 2
			bs_v1430 = ui.get_alpha() > 0
			bs_v1432 = false

			if bs_v1430 and bs_tab_dummy then
				bs_v1435, bs_v1438 = pcall(function()
					return bs_tab_dummy:get()
				end)
				bs_v1432 = bs_v1435 and bs_v1438 == 2
			end

			if bs_v1432 then
				bs_v382:update(vector(bs_v1415, bs_v1428))
			end

			bs_v1434 = math.max(bs_v382.hover_anim, bs_v382.grab_anim)

			if bs_v1434 > 0.005 then
				bs_draw_panel_bg(bs_v382.position, vector(bs_v1415, bs_v1428), bs_v1434)
			end

			bs_v1437 = math.floor(bs_v382.position.x)
			bs_v1440 = math.floor(bs_v382.position.y)
			bs_v1396 = bs_v1437 - math.floor(bs_v338 * 0.5)
			bs_v1398 = bs_v1440 - math.floor(bs_v350 * 0.5)
			bs_v1400 = bs_v1393.w_col and bs_v1393.w_col:get() or color(255, 255, 255, 255)

			render.texture(bs_v325, vector(bs_v1396, bs_v1398), vector(bs_v338, bs_v350), color(bs_v1400.r, bs_v1400.g, bs_v1400.b, bs_v1400.a))
		end

		return
	end

	bs_v1414 = bs_menu.info.crosshair

	if not bs_v1414 then
		return
	end

	if bs_v1414.enabled:get() then
		return
	end

	bs_v1427 = bs_v1393.col1:get()
	bs_v1429 = bs_v1393.col2:get()
	bs_v1431 = bs_v1393.col3:get()
	bs_v1433 = bs_v1393.col_wave:get()
	bs_v1436 = render.screen_size()
	bs_v1439 = bs_v1393.position:get()
	bs_v1395 = bs_v1393 and bs_v1393.font and bs_v1393.font:get() == "pixel"
	bs_v1397 = nil
	bs_v1399 = nil

	if bs_v1439 == "bottom center" then
		bs_v1397 = bs_v1436.x * 0.5
		bs_v1399 = bs_v1436.y - (bs_v1395 and 20 or 28)
	elseif bs_v1439 == "left center" then
		bs_v1397 = bs_v1395 and 32 or 43
		bs_v1399 = bs_v1436.y * 0.5
	else
		bs_v1397 = bs_v1436.x * 0.5
		bs_v1399 = bs_v1436.y - 28
	end

	bs_v1401 = bs_v399(bs_v1393)
	bs_v1402 = bs_v407(bs_v1393)
	bs_v1403 = {}
	bs_v1404 = {}
	bs_v1405 = 0

	for iter_461_0 = 1, #bs_v1402 do
		bs_v1403[iter_461_0] = bs_v1402:sub(iter_461_0, iter_461_0)
		bs_v1411 = render.measure_text(bs_v1401, nil, bs_v1403[iter_461_0])
		bs_v1404[iter_461_0] = bs_v1411.x
		bs_v1405 = bs_v1405 + bs_v1411.x
	end

	bs_v1406 = render.measure_text(bs_v1401, nil, "A").y
	bs_v1407 = 165
	bs_v1409 = (math.sin(globals.realtime * 1.6) + 1) * 0.5 * 1.4 - 0.2
	bs_v1410 = bs_v1397 - bs_v1405 * 0.5
	bs_v1412 = bs_v1410

	for iter_461_1, iter_461_2 in ipairs(bs_v1403) do
		bs_v1413 = (bs_v1412 - bs_v1410 + bs_v1404[iter_461_1] * 0.5) / math.max(bs_v1405, 1)
		bs_v1416 = bs_v1413 < 0.5 and bs_v415(bs_v1427, bs_v1429, bs_v1413 * 2) or bs_v415(bs_v1429, bs_v1431, (bs_v1413 - 0.5) * 2)
		bs_v1417 = math.abs(bs_v1413 - bs_v1409)
		bs_v1419 = math.max(0, 1 - bs_v1417 / 0.38)
		bs_v1418 = bs_v1419 * bs_v1419 * (3 - 2 * bs_v1419)
		bs_v1421 = bs_v415(bs_v1416, bs_v1433, bs_v1418 * 0.6)
		bs_v1422 = math.min(255, math.floor(bs_v1407 + bs_v1418 * 90))
		bs_v1420 = color(bs_v1421.r, bs_v1421.g, bs_v1421.b, bs_v1422)

		render.push_clip_rect(vector(bs_v1412 - 2, bs_v1399 - 2), vector(bs_v1412 + bs_v1404[iter_461_1] + 2, bs_v1399 + bs_v1406 + 2))

		bs_v1423 = math.floor(bs_v1422 * 0.09)
		bs_v1424 = math.floor(bs_v1423 * 0.5)

		if bs_v1423 > 0 then
			bs_v1425 = color(bs_v1420.r, bs_v1420.g, bs_v1420.b, bs_v1423)
			bs_v1426 = color(bs_v1420.r, bs_v1420.g, bs_v1420.b, bs_v1424)

			render.text(bs_v1401, vector(bs_v1412, bs_v1399 - 1), bs_v1425, nil, iter_461_2)
			render.text(bs_v1401, vector(bs_v1412, bs_v1399 + 1), bs_v1425, nil, iter_461_2)
			render.text(bs_v1401, vector(bs_v1412 - 1, bs_v1399), bs_v1425, nil, iter_461_2)
			render.text(bs_v1401, vector(bs_v1412 + 1, bs_v1399), bs_v1425, nil, iter_461_2)
			render.text(bs_v1401, vector(bs_v1412 - 1, bs_v1399 - 1), bs_v1426, nil, iter_461_2)
			render.text(bs_v1401, vector(bs_v1412 + 1, bs_v1399 - 1), bs_v1426, nil, iter_461_2)
			render.text(bs_v1401, vector(bs_v1412 - 1, bs_v1399 + 1), bs_v1426, nil, iter_461_2)
			render.text(bs_v1401, vector(bs_v1412 + 1, bs_v1399 + 1), bs_v1426, nil, iter_461_2)
		end

		render.text(bs_v1401, vector(bs_v1412, bs_v1399), bs_v1420, nil, iter_461_2)
		render.pop_clip_rect()

		bs_v1412 = bs_v1412 + bs_v1404[iter_461_1]
	end
end)

bs_v715 = nil
bs_v727 = bs_position_dragger:new("hotkeys_list", vector(bs_screen_size.x - 180, bs_screen_size.y * 0.5), "xy")
bs_v741 = 28
bs_v751 = 3
bs_v763 = 20
bs_v9 = 10
bs_v24 = 3
bs_v37 = 9
bs_v52 = 109
bs_v67 = "hotkeys"
bs_v82 = 0
bs_v99 = 0
bs_v113 = 119
bs_v130 = 0
bs_v133 = 0
bs_v151 = 0
bs_v175 = 0
bs_v198 = 8
bs_v218 = {}
bs_v238 = {}
bs_v257 = {}

function bs_v272(arg_463_0, arg_463_1, arg_463_2, arg_463_3, arg_463_4, arg_463_5, arg_463_6, arg_463_7, arg_463_8)
	local var_463_0 = math.floor(arg_463_6.a * 0.2)

	if var_463_0 > 1 then
		render.rect(vector(arg_463_0 - 2, arg_463_1), vector(arg_463_2 + 2, arg_463_3 + 4), color(0, 0, 0, var_463_0), arg_463_4 + 2)
	end

	if arg_463_5 and arg_463_8 > 0.01 then
		render.blur(vector(arg_463_0, arg_463_1), vector(arg_463_2, arg_463_3), 6, 0.85 * arg_463_8, arg_463_4)
		render.blur(vector(arg_463_0, arg_463_1), vector(arg_463_2, arg_463_3), 3, 0.55 * arg_463_8, arg_463_4)
		render.blur(vector(arg_463_0, arg_463_1), vector(arg_463_2, arg_463_3), 1, 0.25 * arg_463_8, arg_463_4)
	end

	render.rect(vector(arg_463_0, arg_463_1), vector(arg_463_2, arg_463_3), color(arg_463_6.r, arg_463_6.g, arg_463_6.b, arg_463_6.a), arg_463_4)

	local var_463_1 = arg_463_3 - arg_463_1

	render.rect(vector(arg_463_0 + 1, arg_463_1 + 1), vector(arg_463_2 - 1, arg_463_1 + 1 + math.floor(var_463_1 * 0.44)), color(255, 255, 255, math.floor(22 * arg_463_8)), arg_463_4)
	render.rect_outline(vector(arg_463_0, arg_463_1), vector(arg_463_2, arg_463_3), color(arg_463_7.r, arg_463_7.g, arg_463_7.b, arg_463_7.a), 1, arg_463_4)
end

function bs_v286(arg_464_0, arg_464_1, arg_464_2, arg_464_3, arg_464_4, arg_464_5, arg_464_6, arg_464_7, arg_464_8)
	local var_464_0 = math.floor(arg_464_6.a * 0.2)

	if var_464_0 > 1 then
		render.rect(vector(arg_464_0 - 2, arg_464_1), vector(arg_464_2 + 2, arg_464_3 + 4), color(0, 0, 0, var_464_0), arg_464_4 + 2)
	end

	if arg_464_5 and arg_464_8 > 0.01 then
		render.blur(vector(arg_464_0, arg_464_1), vector(arg_464_2, arg_464_3), 6, 0.85 * arg_464_8, arg_464_4)
		render.blur(vector(arg_464_0, arg_464_1), vector(arg_464_2, arg_464_3), 3, 0.55 * arg_464_8, arg_464_4)
		render.blur(vector(arg_464_0, arg_464_1), vector(arg_464_2, arg_464_3), 1, 0.25 * arg_464_8, arg_464_4)
	end

	render.rect(vector(arg_464_0, arg_464_1), vector(arg_464_2, arg_464_3), color(arg_464_6.r, arg_464_6.g, arg_464_6.b, arg_464_6.a), arg_464_4)
	render.rect_outline(vector(arg_464_0, arg_464_1), vector(arg_464_2, arg_464_3), color(arg_464_7.r, arg_464_7.g, arg_464_7.b, arg_464_7.a), 1, arg_464_4)
end

function bs_v312(arg_465_0)
	if not arg_465_0 or arg_465_0 == "" then
		return arg_465_0
	end

	local var_465_0 = arg_465_0:lower()

	if var_465_0:find("ai peek") or var_465_0:find("robot") then
		return "aipeek"
	end

	if var_465_0:find("air exploit") or var_465_0:find("plane%-up") then
		return "airexploit"
	end

	if var_465_0:find("freestand") or var_465_0:find("rotate") then
		return "freestanding"
	end

	arg_465_0 = arg_465_0:gsub("[%c]", "")
	arg_465_0 = arg_465_0:gsub("%b<>", "")
	arg_465_0 = arg_465_0:gsub("[^\x01-\x7F]", "")
	arg_465_0 = arg_465_0:gsub("\a%x%x%x%x%x%x%x%x", "")
	arg_465_0 = arg_465_0:gsub("\\a%x%x%x%x%x%x%x%x", "")
	arg_465_0 = arg_465_0:gsub("^%s+", "")
	arg_465_0 = arg_465_0:gsub("%s+$", "")

	return arg_465_0:lower()
end

function bs_v324(arg_466_0)
	if arg_466_0.name and arg_466_0.name:lower() == "min. damage" then
		local var_466_0, var_466_1 = pcall(function()
			return bs_config.rage.selection.minimum_damage:get()
		end)

		if var_466_0 and type(var_466_1) == "number" then
			return tostring(math.floor(var_466_1))
		end
	end

	return "on"
end

function bs_v337(arg_468_0)
	if not arg_468_0 then
		return nil
	end

	local var_468_0, var_468_1 = pcall(function()
		return arg_468_0:get()
	end)

	return var_468_0 and var_468_1 or nil
end

events.render(function()
	bs_v1441 = bs_menu.info and bs_menu.info.keybinds_ui

	if not bs_v1441 then
		return
	end

	if not bs_v337(bs_v1441.enabled) then
		return
	end

	bs_v1442 = ui.get_alpha() > 0
	bs_v1460 = false

	if bs_v1442 and bs_tab_dummy then
		bs_v1475, bs_v1488 = pcall(function()
			return bs_tab_dummy:get()
		end)
		bs_v1460 = bs_v1475 and bs_v1488 == 2
	end

	bs_v1474 = bs_v1442 and bs_v1460

	if entity.get_local_player() == nil and not bs_v1474 then
		return
	end

	bs_v1504 = math.max(0.001, math.min(globals.frametime, 0.05))
	bs_v82 = bs_v82 + bs_v1504
	bs_v99 = bs_v99 + bs_v1504
	bs_v1515 = bs_v337(bs_v1441.col_bg) or color(15, 15, 18, 210)
	bs_v1532 = bs_v337(bs_v1441.col_border) or color(255, 255, 255, 40)
	bs_v1542 = bs_v337(bs_v1441.col_text) or color(133, 133, 133, 191)
	bs_v1548 = bs_v337(bs_v1441.col_accent) or bs_get_accent()
	bs_v1443 = bs_blur_func()
	bs_v1444 = true

	if bs_v1441.show_bg then
		bs_v1446, bs_v1448 = pcall(function()
			return bs_v1441.show_bg:get()
		end)

		if bs_v1446 then
			bs_v1444 = bs_v1448 ~= false
		end
	end

	bs_v1445 = {}
	bs_v1447, bs_v1449 = pcall(ui.get_binds)

	if bs_v1447 and bs_v1449 then
		for iter_470_0, iter_470_1 in ipairs(bs_v1449) do
			if iter_470_1.value and iter_470_1.value ~= 0 then
				bs_v1445[#bs_v1445 + 1] = iter_470_1
			end
		end
	end

	if bs_auto_hide_shots and bs_auto_hide_shots.is_active or false then
		bs_v1451 = nil
		bs_v1453 = nil

		for iter_470_2, iter_470_3 in ipairs(bs_v1445) do
			bs_v1466 = iter_470_3.name and iter_470_3.name:lower()

			if bs_v1466 == "double tap" then
				bs_v1451 = iter_470_2
			end

			if bs_v1466 == "hide shots" then
				bs_v1453 = iter_470_2
			end
		end

		if bs_v1451 and not bs_v1453 then
			bs_v1457 = bs_v1445[bs_v1451]
			bs_v1445[bs_v1451] = {
				active = true,
				name = "hide shots",
				value = bs_v1457.value,
				mode = bs_v1457.mode
			}
		elseif bs_v1451 and bs_v1453 then
			table.remove(bs_v1445, bs_v1451)

			bs_v1456 = bs_v1451 < bs_v1453 and bs_v1453 - 1 or bs_v1453
			bs_v1459 = bs_v1445[bs_v1456]
			bs_v1445[bs_v1456] = {
				active = true,
				name = bs_v1459.name,
				value = bs_v1459.value,
				mode = bs_v1459.mode
			}
		elseif not bs_v1451 and not bs_v1453 then
			bs_v1445[#bs_v1445 + 1] = {
				value = 1,
				active = true,
				mode = "toggle",
				name = "hide shots"
			}
		elseif bs_v1453 then
			bs_v1455 = bs_v1445[bs_v1453]
			bs_v1445[bs_v1453] = {
				active = true,
				name = bs_v1455.name,
				value = bs_v1455.value,
				mode = bs_v1455.mode
			}
		end
	end

	if bs_v1474 and #bs_v1445 == 0 then
		bs_v1445 = {
			{
				value = 1,
				active = true,
				mode = "toggle",
				name = "double tap"
			},
			{
				value = 2,
				active = false,
				mode = "toggle",
				name = "hide shots"
			},
			{
				value = 3,
				active = true,
				mode = "hold",
				name = "min. damage"
			}
		}
	end

	bs_v1450 = {}

	for iter_470_4, iter_470_5 in ipairs(bs_v1445) do
		bs_v1450[iter_470_5.name] = true
	end

	bs_v1452 = {
		["min. damage"] = 3,
		["hide shots"] = 2,
		["double tap"] = 1
	}

	function bs_v1454(arg_473_0)
		return bs_v1452[arg_473_0 and arg_473_0:lower()] or 999
	end

	bs_v1458 = math.min(1, bs_v1504 * 18)
	bs_v1461 = math.min(1, bs_v1504 * 30)

	for iter_470_6, iter_470_7 in ipairs(bs_v1445) do
		if not bs_v218[iter_470_7.name] then
			bs_v218[iter_470_7.name] = 0
			bs_v238[iter_470_7.name] = -bs_v198
			bs_v257[#bs_v257 + 1] = iter_470_7.name
		end

		if bs_v1474 then
			bs_v218[iter_470_7.name] = 1
			bs_v238[iter_470_7.name] = 0
		else
			bs_v218[iter_470_7.name] = bs_v218[iter_470_7.name] + (1 - bs_v218[iter_470_7.name]) * bs_v1458
			bs_v238[iter_470_7.name] = bs_v238[iter_470_7.name] + (0 - bs_v238[iter_470_7.name]) * bs_v1458
		end
	end

	for iter_470_8 = #bs_v257, 1, -1 do
		bs_v1469 = bs_v257[iter_470_8]

		if not bs_v1450[bs_v1469] then
			if bs_v1474 then
				bs_v218[bs_v1469] = 0

				table.remove(bs_v257, iter_470_8)

				bs_v218[bs_v1469] = nil
				bs_v238[bs_v1469] = nil
			else
				bs_v218[bs_v1469] = bs_v218[bs_v1469] + (0 - bs_v218[bs_v1469]) * bs_v1461
				bs_v238[bs_v1469] = bs_v238[bs_v1469] + (-bs_v198 - bs_v238[bs_v1469]) * bs_v1461

				if (bs_v218[bs_v1469] or 0) < 0.015 then
					table.remove(bs_v257, iter_470_8)

					bs_v218[bs_v1469] = nil
					bs_v238[bs_v1469] = nil
				end
			end
		end
	end

	table.sort(bs_v257, function(arg_474_0, arg_474_1)
		local var_474_0 = bs_v1454(arg_474_0)
		local var_474_1 = bs_v1454(arg_474_1)

		if var_474_0 ~= var_474_1 then
			return var_474_0 < var_474_1
		end

		return arg_474_0 < arg_474_1
	end)

	bs_v1462 = #bs_v257
	bs_v1463 = bs_v1462 > 0 and 1 or 0

	if bs_v1474 and bs_v1462 > 0 then
		bs_v175 = 1
	else
		bs_v1465 = bs_v1463 < bs_v175 and math.min(1, bs_v1504 * 22) or math.min(1, bs_v1504 * 12)
		bs_v175 = bs_v175 + (bs_v1463 - bs_v175) * bs_v1465
	end

	bs_v1464 = bs_v175

	if bs_v1464 < 0.01 then
		return
	end

	bs_v1467 = bs_v1441.font and (function()
		local var_475_0, var_475_1 = pcall(function()
			return bs_v1441.font:get()
		end)

		return var_475_0 and var_475_1 == "verdana"
	end)()
	bs_v1468 = bs_v1467 and bs_font_13b or bs_font_13
	bs_v1470 = bs_v1467 and bs_font_12c or bs_font_12b
	bs_v1471 = render.measure_text(bs_v1470, nil, "A").y
	bs_v1472 = render.measure_text(bs_v1468, nil, bs_v67)
	bs_v1473 = 18
	bs_v1476 = bs_v1472.x + bs_v1473 * 2
	bs_v1477 = {}

	for iter_470_9, iter_470_10 in ipairs(bs_v1445) do
		bs_v1477[iter_470_10.name] = iter_470_10
	end

	bs_v1478 = 0
	bs_v1479 = 0

	for iter_470_11, iter_470_12 in ipairs(bs_v257) do
		bs_v1487 = bs_v1477[iter_470_12]
		bs_v1491 = bs_v312(iter_470_12)
		bs_v1493 = bs_v1487 and bs_v324(bs_v1487) or "on"
		bs_v1495 = render.measure_text(bs_v1470, nil, bs_v1491).x
		bs_v1497 = render.measure_text(bs_v1470, nil, bs_v1493).x

		if bs_v1478 < bs_v1495 then
			bs_v1478 = bs_v1495
		end

		if bs_v1479 < bs_v1497 then
			bs_v1479 = bs_v1497
		end
	end

	bs_v1480 = bs_v1462 > 0 and bs_v9 + bs_v1478 + 16 + bs_v1479 + bs_v9 or 0
	bs_v1481 = math.max(bs_v52, bs_v1476, bs_v1480)

	if bs_v1474 then
		bs_v113 = bs_v1481
	else
		bs_v113 = bs_v113 + (bs_v1481 - bs_v113) * math.min(1, bs_v1504 * 18)
	end

	bs_v1482 = math.floor(bs_v113 + 0.5)
	bs_v1483 = bs_v1462 > 0 and bs_v24 + bs_v1462 * bs_v763 + math.max(0, bs_v1462 - 1) * 4 + bs_v24 or 0
	bs_v1484 = math.min(1, bs_v1504 * 22)

	if bs_v1474 then
		bs_v130 = bs_v1483
		bs_v133 = bs_v1462 > 0 and bs_v1482 or 0
		bs_v151 = bs_v1462 > 0 and 1 or 0
	else
		bs_v130 = bs_v130 + (bs_v1483 - bs_v130) * bs_v1484
		bs_v1486 = bs_v1462 > 0 and bs_v1482 or 0
		bs_v133 = bs_v133 + (bs_v1486 - bs_v133) * bs_v1484
		bs_v1490 = bs_v1462 > 0 and 1 or 0
		bs_v151 = bs_v151 + (bs_v1490 - bs_v151) * math.min(1, bs_v1504 * 5)
	end

	bs_v1485 = math.floor(bs_v130 + 0.5)
	bs_v1489 = math.floor(bs_v133 + 0.5)
	bs_v1492 = bs_v1485 > 2 and bs_v151 * bs_v1464 > 0.01
	bs_v1494 = bs_v741 + (bs_v1492 and bs_v751 + bs_v1485 or 0)

	bs_v727:update(vector(bs_v1482, bs_v1494))

	bs_v1496 = math.max(bs_v727.hover_anim, bs_v727.grab_anim)

	if bs_v1496 > 0.005 then
		bs_draw_panel_bg(bs_v727.position, vector(bs_v1482, bs_v1494), bs_v1496)
	end

	bs_v1498 = math.floor(bs_v727.position.x)
	bs_v1499 = math.floor(bs_v727.position.y)
	bs_v1500 = bs_v1498 - math.floor(bs_v1482 * 0.5)
	bs_v1501 = bs_v1499 - math.floor(bs_v1494 * 0.5)
	bs_v1502 = bs_v1500
	bs_v1503 = bs_v1501
	bs_v1505 = bs_v1500 + bs_v1482
	bs_v1506 = bs_v1501 + bs_v741
	bs_v1507 = color(bs_v1515.r, bs_v1515.g, bs_v1515.b, math.floor(bs_v1515.a * bs_v1464))
	bs_v1508 = color(bs_v1532.r, bs_v1532.g, bs_v1532.b, math.floor(bs_v1532.a * bs_v1464))

	bs_v272(bs_v1502, bs_v1503, bs_v1505, bs_v1506, bs_v37, bs_v1443, bs_v1507, bs_v1508, bs_v1464)

	bs_v1509 = bs_v99 * 0.55 % 1.3 - 0.15
	bs_v1510 = (math.sin(bs_v82 * 1.4) + 1) * 0.5
	bs_v1511 = bs_v1472.x
	bs_v1512 = bs_v1498 - math.floor(bs_v1511 * 0.5)
	bs_v1513 = bs_v1503 + math.floor((bs_v741 - bs_v1472.y) * 0.5)
	bs_v1514 = bs_v1512

	for iter_470_13 = 1, #bs_v67 do
		bs_v1521 = bs_v67:sub(iter_470_13, iter_470_13)
		bs_v1524 = render.measure_text(bs_v1468, nil, bs_v1521)
		bs_v1527 = (bs_v1514 - bs_v1512 + bs_v1524.x * 0.5) / math.max(bs_v1511, 1)
		bs_v1528 = math.abs(bs_v1527 - bs_v1509)
		bs_v1530 = math.max(0, 1 - bs_v1528 / 0.15)
		bs_v1529 = bs_v1530 * bs_v1530 * bs_v1530
		bs_v1531 = math.floor(bs_v1548.a * bs_v1464 * (0.88 + bs_v1510 * 0.12))
		bs_v1533 = math.floor(bs_v1548.a * bs_v1464 * bs_v1529 * 0.3)

		if bs_v1533 > 2 then
			render.text(bs_v1468, vector(bs_v1514 + 1, bs_v1513 + 1), color(bs_v1548.r, bs_v1548.g, bs_v1548.b, bs_v1533), nil, bs_v1521)
			render.text(bs_v1468, vector(bs_v1514 - 1, bs_v1513), color(bs_v1548.r, bs_v1548.g, bs_v1548.b, math.floor(bs_v1533 * 0.5)), nil, bs_v1521)
			render.text(bs_v1468, vector(bs_v1514, bs_v1513 - 1), color(bs_v1548.r, bs_v1548.g, bs_v1548.b, math.floor(bs_v1533 * 0.4)), nil, bs_v1521)
		end

		render.text(bs_v1468, vector(bs_v1514, bs_v1513), color(bs_v1548.r, bs_v1548.g, bs_v1548.b, bs_v1531), nil, bs_v1521)

		bs_v1514 = bs_v1514 + bs_v1524.x
	end

	if bs_v1492 then
		bs_v1516 = bs_v1500
		bs_v1517 = bs_v1506 + bs_v751
		bs_v1518 = bs_v1500 + bs_v1482
		bs_v1519 = bs_v1517 + bs_v1485
		bs_v1520 = bs_v151 * bs_v1464

		if bs_v1444 then
			bs_v1523 = color(bs_v1515.r, bs_v1515.g, bs_v1515.b, math.floor(bs_v1515.a * bs_v1520))
			bs_v1526 = color(bs_v1532.r, bs_v1532.g, bs_v1532.b, math.floor(bs_v1532.a * bs_v1520))

			bs_v286(bs_v1516, bs_v1517, bs_v1518, bs_v1519, bs_v37, bs_v1443, bs_v1523, bs_v1526, bs_v1520)
		end

		bs_v1522 = math.floor(bs_v1489 * 0.5)

		render.push_clip_rect(vector(bs_v1498 - bs_v1522, bs_v1517 - 1), vector(bs_v1498 + bs_v1522, bs_v1519 + 2))

		bs_v1525 = bs_v1517 + bs_v24

		for iter_470_14, iter_470_15 in ipairs(bs_v257) do
			if bs_v1525 + bs_v1471 > bs_v1519 + 4 then
				break
			end

			bs_v1534 = bs_v1477[iter_470_15]
			bs_v1535 = bs_v312(iter_470_15)
			bs_v1536 = bs_v1534 and bs_v1534.active or false
			bs_v1537 = bs_v1536 and (bs_v1534 and bs_v324(bs_v1534) or "on") or "off"
			bs_v1538 = bs_v1536 and 1 or 0.45
			bs_v1539 = (bs_v218[iter_470_15] or 0) * bs_v1464
			bs_v1540 = bs_v238[iter_470_15] or 0
			bs_v1541 = math.floor(bs_v1542.a * bs_v1539 * bs_v1538)
			bs_v1543 = math.floor(bs_v1548.a * bs_v1539 * bs_v1538)
			bs_v1544 = math.floor(bs_v1540)
			bs_v1545 = bs_v1525 + math.floor((bs_v763 - bs_v1471) * 0.5)

			render.text(bs_v1470, vector(bs_v1516 + bs_v9 + bs_v1544, bs_v1545), color(bs_v1542.r, bs_v1542.g, bs_v1542.b, bs_v1541), nil, bs_v1535)
			render.text(bs_v1470, vector(bs_v1518 - bs_v9 + bs_v1544, bs_v1545), color(bs_v1548.r, bs_v1548.g, bs_v1548.b, bs_v1543), "r", bs_v1537)

			if bs_v1444 and iter_470_14 < bs_v1462 then
				bs_v1546 = bs_v1525 + bs_v763 + 2
				bs_v1547 = math.floor(bs_v1532.a * 0.35 * bs_v1539)

				if bs_v1547 > 1 then
					render.line(vector(bs_v1516 + bs_v9, bs_v1546), vector(bs_v1518 - bs_v9, bs_v1546), color(bs_v1532.r, bs_v1532.g, bs_v1532.b, bs_v1547))
				end
			end

			bs_v1525 = bs_v1525 + bs_v763 + 4
		end

		render.pop_clip_rect()
	end
end)

bs_v726 = nil
bs_v738 = {
	left = 1,
	forward = 3,
	right = 2
}
bs_v761 = ui.create("DRAGGING_arrows"):slider("arrows:gap", 20, 120, 42)

bs_v761:visibility(false)
bs_add_round_cb(function()
	bs_v761:set(42)
end)
table.insert(bs_reset_cbs, {
	key = "arr:gap",
	get = function()
		return bs_v761:get()
	end,
	set = function(arg_479_0)
		bs_v761:set(arg_479_0)
	end
})

bs_v8 = 5
bs_v23 = bs_v8 + 2
bs_v36 = bs_v8 * 0.65
bs_v51 = 10
bs_v66 = 14
bs_v81 = render.load_font("Verdana", 22, "bs")

function bs_v98(arg_480_0, arg_480_1, arg_480_2)
	return arg_480_0 + (arg_480_1 - arg_480_0) * arg_480_2
end

function bs_v112(arg_481_0, arg_481_1, arg_481_2, arg_481_3, arg_481_4, arg_481_5, arg_481_6)
	if arg_481_3 < 0.01 then
		return
	end

	if arg_481_6 == "old" then
		bs_v1551 = arg_481_5 == 1 and "<" or arg_481_5 == 2 and ">" or arg_481_5 == 3 and "^" or nil

		if not bs_v1551 then
			return
		end

		bs_v1555 = arg_481_0
		bs_v1556 = arg_481_1

		if arg_481_5 == 1 then
			bs_v1555 = arg_481_0 - arg_481_4
		elseif arg_481_5 == 2 then
			bs_v1555 = arg_481_0 + arg_481_4
		elseif arg_481_5 == 3 then
			bs_v1556 = arg_481_1 - arg_481_4
		end

		bs_v1549 = render.measure_text(bs_v81, nil, bs_v1551)

		render.text(bs_v81, vector(math.floor(bs_v1555 - bs_v1549.x * 0.5), math.floor(bs_v1556 - bs_v1549.y * 0.5)), color(arg_481_2.r, arg_481_2.g, arg_481_2.b, math.max(0, math.min(255, math.floor(arg_481_2.a * arg_481_3)))), nil, bs_v1551)

		return
	end

	function bs_v1550(arg_482_0, arg_482_1, arg_482_2, arg_482_3, arg_482_4)
		render.line(vector(arg_482_0, arg_482_1), vector(arg_482_2, arg_482_3), color(arg_481_2.r, arg_481_2.g, arg_481_2.b, math.max(0, math.min(255, math.floor(arg_481_2.a * arg_481_3 * arg_482_4)))))
	end

	if arg_481_5 == 1 then
		bs_v1554 = arg_481_0 - arg_481_4

		bs_v1550(bs_v1554, arg_481_1, bs_v1554 + bs_v23, arg_481_1 - bs_v23, 0.22)
		bs_v1550(bs_v1554, arg_481_1, bs_v1554 + bs_v23, arg_481_1 + bs_v23, 0.22)
		bs_v1550(bs_v1554, arg_481_1, bs_v1554 + bs_v8, arg_481_1 - bs_v8, 0.6)
		bs_v1550(bs_v1554, arg_481_1, bs_v1554 + bs_v8, arg_481_1 + bs_v8, 0.6)
		bs_v1550(bs_v1554, arg_481_1, bs_v1554 + bs_v36, arg_481_1 - bs_v36, 1)
		bs_v1550(bs_v1554, arg_481_1, bs_v1554 + bs_v36, arg_481_1 + bs_v36, 1)
	elseif arg_481_5 == 2 then
		bs_v1553 = arg_481_0 + arg_481_4

		bs_v1550(bs_v1553, arg_481_1, bs_v1553 - bs_v23, arg_481_1 - bs_v23, 0.22)
		bs_v1550(bs_v1553, arg_481_1, bs_v1553 - bs_v23, arg_481_1 + bs_v23, 0.22)
		bs_v1550(bs_v1553, arg_481_1, bs_v1553 - bs_v8, arg_481_1 - bs_v8, 0.6)
		bs_v1550(bs_v1553, arg_481_1, bs_v1553 - bs_v8, arg_481_1 + bs_v8, 0.6)
		bs_v1550(bs_v1553, arg_481_1, bs_v1553 - bs_v36, arg_481_1 - bs_v36, 1)
		bs_v1550(bs_v1553, arg_481_1, bs_v1553 - bs_v36, arg_481_1 + bs_v36, 1)
	elseif arg_481_5 == 3 then
		bs_v1552 = arg_481_1 - arg_481_4

		bs_v1550(arg_481_0, bs_v1552, arg_481_0 - bs_v23, bs_v1552 + bs_v23, 0.22)
		bs_v1550(arg_481_0, bs_v1552, arg_481_0 + bs_v23, bs_v1552 + bs_v23, 0.22)
		bs_v1550(arg_481_0, bs_v1552, arg_481_0 - bs_v8, bs_v1552 + bs_v8, 0.6)
		bs_v1550(arg_481_0, bs_v1552, arg_481_0 + bs_v8, bs_v1552 + bs_v8, 0.6)
		bs_v1550(arg_481_0, bs_v1552, arg_481_0 - bs_v36, bs_v1552 + bs_v36, 1)
		bs_v1550(arg_481_0, bs_v1552, arg_481_0 + bs_v36, bs_v1552 + bs_v36, 1)
	end
end

bs_v129 = {
	hover_anim = 0,
	grab_anim = 0,
	grabbed_id = 0,
	dragging = false,
	drag_start_gap = 0,
	drag_start_x = 0
}

function bs_v146(arg_483_0, arg_483_1, arg_483_2)
	if not arg_483_2 then
		bs_v129.dragging = false
		bs_v129.grab_anim = bs_v129.grab_anim + (0 - bs_v129.grab_anim) * 0.1

		return
	end

	local var_483_0 = false

	if bs_tab_dummy then
		local var_483_1, var_483_2 = pcall(function()
			return bs_tab_dummy:get()
		end)

		var_483_0 = var_483_1 and var_483_2 == 2
	end

	if not var_483_0 then
		bs_v129.dragging = false

		return
	end

	local var_483_3 = ui.get_mouse_position()
	local var_483_4 = common.is_button_down(1)
	local var_483_5 = bs_v761:get()
	local var_483_6 = var_483_5

	if var_483_4 and not bs_confirm_anim.visible then
		if not bs_v129.dragging then
			if bs_scope_zoom == nil then
				for iter_483_0, iter_483_1 in ipairs({
					1,
					2
				}) do
					local var_483_7 = iter_483_1 == 1 and arg_483_0 - var_483_6 or arg_483_0 + var_483_6
					local var_483_8 = 16

					if var_483_8 > math.abs(var_483_3.x - var_483_7) and var_483_8 > math.abs(var_483_3.y - arg_483_1) then
						bs_v129.dragging = true
						bs_scope_zoom = bs_v129
						bs_v129.drag_start_x = var_483_3.x
						bs_v129.drag_start_gap = var_483_5
						bs_v129.grabbed_id = iter_483_1

						break
					end
				end
			end
		else
			local var_483_9 = var_483_3.x - bs_v129.drag_start_x
			local var_483_10

			if bs_v129.grabbed_id == 1 then
				var_483_10 = bs_v129.drag_start_gap - var_483_9
			else
				var_483_10 = bs_v129.drag_start_gap + var_483_9
			end

			local var_483_11 = math.max(20, math.min(120, var_483_10))

			bs_v761:set(var_483_11)
		end
	else
		if bs_v129.dragging then
			bs_scope_zoom = nil
		end

		bs_v129.dragging = false
	end

	local var_483_12 = bs_v129.dragging and 1 or 0

	bs_v129.grab_anim = bs_v129.grab_anim + (var_483_12 - bs_v129.grab_anim) * 0.14

	local var_483_13 = bs_v761:get()
	local var_483_14 = ui.get_mouse_position()
	local var_483_15 = false

	for iter_483_2, iter_483_3 in ipairs({
		1,
		2
	}) do
		local var_483_16 = iter_483_3 == 1 and arg_483_0 - var_483_13 or arg_483_0 + var_483_13

		if math.abs(var_483_14.x - var_483_16) < 20 and math.abs(var_483_14.y - arg_483_1) < 20 then
			var_483_15 = true
		end
	end

	local var_483_17 = var_483_15 and 1 or 0

	bs_v129.hover_anim = (bs_v129.hover_anim or 0) + (var_483_17 - (bs_v129.hover_anim or 0)) * 0.12
end

bs_v150 = {
	{
		a = 0,
		d = 0
	},
	{
		a = 0,
		d = 0
	},
	{
		a = 0,
		d = 0
	}
}

function bs_v174(arg_485_0, arg_485_1, arg_485_2, arg_485_3, arg_485_4, arg_485_5)
	local var_485_0 = arg_485_4 + bs_v51

	for iter_485_0 = 1, 3 do
		local var_485_1 = arg_485_3 == iter_485_0 and 1 or 0

		bs_v150[iter_485_0].a = bs_v98(bs_v150[iter_485_0].a, var_485_1, 0.14)
		bs_v150[iter_485_0].d = bs_v98(bs_v150[iter_485_0].d, var_485_1, 0.12)

		if bs_v150[iter_485_0].a > 0.01 then
			bs_v112(arg_485_0, arg_485_1, arg_485_2, bs_v150[iter_485_0].a, arg_485_4 + (var_485_0 - arg_485_4) * bs_v150[iter_485_0].d, iter_485_0, arg_485_5)
		end
	end
end

bs_v197 = 6
bs_v217 = 55
bs_v237 = 0
bs_v256 = 0
bs_v283 = 0
bs_v298 = 0
bs_v311 = 0
bs_v323 = 0
bs_v336 = 0
bs_v349 = 0
bs_v363 = 0

function bs_v371(arg_486_0)
	if not arg_486_0 then
		return 0
	end

	local var_486_0 = entity.get_threat(true)

	if not var_486_0 or var_486_0:is_dormant() or not var_486_0:is_alive() then
		return 0
	end

	local var_486_1 = arg_486_0:get_origin()
	local var_486_2 = 0

	pcall(function()
		local var_487_0 = arg_486_0:get_anim_state()

		if var_487_0 then
			var_486_2 = var_487_0.foot_yaw
		end
	end)

	local var_486_3, var_486_4 = pcall(function()
		return var_486_0:get_origin() - var_486_1
	end)

	if not var_486_3 or not var_486_4 then
		return 0
	end

	local var_486_5 = math.deg(math.atan2(var_486_4.y, var_486_4.x)) - var_486_2

	while var_486_5 > 180 do
		var_486_5 = var_486_5 - 360
	end

	while var_486_5 < -180 do
		var_486_5 = var_486_5 + 360
	end

	return var_486_5 < 0 and 1 or 2
end

function bs_v381(arg_489_0, arg_489_1, arg_489_2, arg_489_3, arg_489_4, arg_489_5)
	local var_489_0 = arg_489_3.color_enemy:get()
	local var_489_1 = arg_489_3.color_opposite:get()
	local var_489_2 = bs_v371(arg_489_2)

	if var_489_2 ~= 0 then
		bs_v298 = 0

		if var_489_2 == bs_v256 then
			bs_v283 = bs_v283 + 1
		else
			bs_v256 = var_489_2
			bs_v283 = 1
		end

		if bs_v283 >= bs_v197 then
			bs_v237 = bs_v256
		end
	else
		bs_v283 = 0
		bs_v298 = bs_v298 + 1

		if bs_v298 >= bs_v217 then
			bs_v237 = 0
		end
	end

	local var_489_3 = bs_v237 ~= 0

	bs_v363 = bs_v98(bs_v363, var_489_3 and 1 or 0, var_489_3 and 0.1 or 0.03)
	bs_v311 = bs_v98(bs_v311, bs_v363, var_489_3 and 0.14 or 0.05)

	if bs_v311 < 0.004 then
		bs_v323 = 0
		bs_v336 = 0
		bs_v349 = 0
		bs_v363 = 0

		return
	end

	bs_v323 = bs_v98(bs_v323, bs_v311 * 0.55, 0.1)

	local var_489_4 = var_489_3 and 1 or 0

	bs_v336 = bs_v98(bs_v336, var_489_4, 0.12)
	bs_v349 = bs_v98(bs_v349, var_489_4, 0.08)

	local var_489_5 = arg_489_4 + bs_v51
	local var_489_6 = arg_489_4 + (var_489_5 - arg_489_4) * bs_v336
	local var_489_7 = arg_489_4 + (var_489_5 - arg_489_4) * bs_v349 + bs_v66
	local var_489_8 = bs_v237 ~= 0 and bs_v237 or 2
	local var_489_9 = var_489_8 == 1 and 2 or 1

	bs_v112(arg_489_0, arg_489_1, var_489_0, bs_v311, var_489_6, var_489_8, arg_489_5)
	bs_v112(arg_489_0, arg_489_1, var_489_0, bs_v323, var_489_7, var_489_8, arg_489_5)
	bs_v112(arg_489_0, arg_489_1, var_489_1, bs_v311 * 0.7, var_489_6, var_489_9, arg_489_5)
end

bs_v390 = 2
bs_v398 = 0
bs_v406 = 0
bs_v414 = 0

function bs_v421(arg_490_0, arg_490_1, arg_490_2, arg_490_3)
	local var_490_0 = bs_v761:get()
	local var_490_1 = var_490_0 + bs_v51
	local var_490_2 = arg_490_2.color_enemy:get()
	local var_490_3 = arg_490_2.color_opposite:get()

	if globals.realtime > bs_v398 then
		bs_v390 = bs_v390 == 1 and 2 or 1
		bs_v398 = globals.realtime + 2.2
	end

	local var_490_4 = 1

	bs_v406 = bs_v406 + (var_490_4 - bs_v406) * 0.08
	bs_v414 = bs_v414 + (bs_v406 * 0.55 - bs_v414) * 0.1

	local var_490_5 = var_490_0 + (var_490_1 - var_490_0) * 0.8
	local var_490_6 = var_490_5 + bs_v66
	local var_490_7 = bs_v390
	local var_490_8 = var_490_7 == 1 and 2 or 1

	bs_v112(arg_490_0, arg_490_1, var_490_2, bs_v406 * 0.7, var_490_5, var_490_7, arg_490_3)
	bs_v112(arg_490_0, arg_490_1, var_490_2, bs_v414 * 0.5, var_490_6, var_490_7, arg_490_3)
	bs_v112(arg_490_0, arg_490_1, var_490_3, bs_v406 * 0.5, var_490_5, var_490_8, arg_490_3)

	local var_490_9 = math.max(bs_v129.hover_anim or 0, bs_v129.grab_anim)

	if var_490_9 > 0.005 then
		local var_490_10 = math.floor((bs_v23 + bs_v51) * 2.2)
		local var_490_11 = math.floor((bs_v23 + bs_v51) * 2.2)

		if bs_v129.grab_anim > 0.01 and bs_v129.grabbed_id > 0 then
			local var_490_12 = bs_v129.grabbed_id == 1 and arg_490_0 - var_490_0 or arg_490_0 + var_490_0

			bs_draw_panel_bg(vector(var_490_12, arg_490_1), vector(var_490_10, var_490_11), var_490_9)
		else
			bs_draw_panel_bg(vector(arg_490_0 - var_490_0, arg_490_1), vector(var_490_10, var_490_11), var_490_9)
			bs_draw_panel_bg(vector(arg_490_0 + var_490_0, arg_490_1), vector(var_490_10, var_490_11), var_490_9)
		end
	end
end

events.render(function()
	local var_491_0 = bs_menu.visuals.manual_arrows

	if not var_491_0.switch:get() then
		bs_v311 = 0
		bs_v323 = 0
		bs_v363 = 0
		bs_v237 = 0
		bs_v256 = 0
		bs_v283 = 0
		bs_v298 = 0
		bs_v129.dragging = false

		return
	end

	local var_491_1 = render.screen_size()
	local var_491_2 = var_491_1.x * 0.5
	local var_491_3 = var_491_1.y * 0.5
	local var_491_4 = ui.get_alpha() > 0
	local var_491_5 = bs_v761:get()
	local var_491_6 = var_491_5 + bs_v51

	bs_v146(var_491_2, var_491_3, var_491_4)

	local var_491_7 = var_491_0.style and var_491_0.style:get() or "modern"

	if var_491_4 then
		local var_491_8 = false

		if bs_tab_dummy then
			local var_491_9, var_491_10 = pcall(function()
				return bs_tab_dummy:get()
			end)

			var_491_8 = var_491_9 and var_491_10 == 2
		end

		if var_491_8 then
			bs_v421(var_491_2, var_491_3, var_491_0, var_491_7)

			return
		end
	end

	local var_491_11 = entity.get_local_player()

	if not var_491_11 or not var_491_11:is_alive() then
		return
	end

	local var_491_12 = bs_menu.antiaim.general.manual_yaw.select:get()
	local var_491_13 = var_491_12 ~= "disabled"

	if var_491_13 then
		bs_v174(var_491_2, var_491_3, var_491_0.color:get(), bs_v738[var_491_12] or -1, var_491_5, var_491_7)
	else
		for iter_491_0 = 1, 3 do
			bs_v150[iter_491_0].a = bs_v98(bs_v150[iter_491_0].a, 0, 0.14)

			if bs_v150[iter_491_0].a > 0.01 then
				bs_v112(var_491_2, var_491_3, var_491_0.color:get(), bs_v150[iter_491_0].a, var_491_5 + (var_491_6 - var_491_5) * bs_v150[iter_491_0].d, iter_491_0, var_491_7)
			end
		end
	end

	if var_491_0.dynamic:get() and not var_491_13 then
		bs_v381(var_491_2, var_491_3, var_491_11, var_491_0, var_491_5, var_491_7)
	elseif var_491_13 then
		bs_v311 = bs_v98(bs_v311, 0, 0.08)
		bs_v323 = bs_v98(bs_v323, 0, 0.08)
		bs_v363 = 0

		if bs_v311 < 0.005 then
			bs_v237 = 0
			bs_v256 = 0
			bs_v283 = 0
			bs_v298 = 0
		end
	end
end)

bs_indicators = {
	data = {},
	icon = render.load_image_from_file("materials/panorama/images/icons/ui/bomb_c4.svg", vector(32, 32)),
	font = render.load_font("Calibri Bold", vector(25, 23.5, 0), "da"),
	progress_bar = function(arg_493_0, arg_493_1, arg_493_2, arg_493_3, arg_493_4)
		local var_493_0 = arg_493_4 * arg_493_3

		render.rect(vector(0, 0), vector(20, arg_493_4), color(0, 0, 0, 120))
		render.rect(vector(1, var_493_0 + 1), vector(19, var_493_0 + 1 + arg_493_4 - var_493_0 - 3), color(arg_493_0, arg_493_1, arg_493_2, 120))
	end
}

function bs_indicators.indicator(arg_494_0, arg_494_1, arg_494_2, arg_494_3)
	bs_indicators.data[#bs_indicators.data + 1] = {
		clr = arg_494_0,
		text = arg_494_1,
		pct = arg_494_2 or -1,
		should_draw_bomb = arg_494_3 or false
	}
end

bs_v750 = nil
bs_watermark_pos = bs_position_dragger:new("crosshair_indicators", vector(bs_screen_size.x * 0.5, bs_screen_size.y * 0.5 + 22), "y")
bs_v6 = render.load_font("Verdana", 11, "a")
bs_v22 = 2
bs_v35 = render.load_font("Verdana Bold", 12, "ab")
bs_v50 = render.load_font("Verdana", 10, "ab")
bs_v65 = 2
bs_v80 = render.load_font("Verdana Bold", 10, "ab")
bs_v97 = render.load_font("Calibri Bold", 14, "ab")
bs_v111 = render.load_font("Calibri Bold", 10, "ab")
bs_v128 = 0

function bs_get_font(arg_495_0)
	if arg_495_0 and arg_495_0.font then
		local var_495_0 = arg_495_0.font:get()

		if var_495_0 == "normal" then
			return 1
		end

		if var_495_0 == "pixel" then
			return 2
		end

		if var_495_0 == "bold" then
			return bs_v35
		end
	end

	return bs_v35
end

function bs_v165(arg_496_0)
	if arg_496_0 and arg_496_0.font and arg_496_0.font:get() == "pixel" then
		return bs_v65
	end

	if arg_496_0 and arg_496_0.font and arg_496_0.font:get() == "bold" then
		return bs_v80
	end

	return bs_v50
end

bs_v173 = bs_v6
bs_v196 = {}
bs_v216 = {}
bs_v236 = {}
bs_v255 = ""
bs_v282 = ""
bs_v297 = 1
bs_v310 = 165
bs_v322 = 39
bs_v335 = {
	was_scoped = false,
	x_current = 0,
	x_settled = 0,
	blur_alpha = 0
}
bs_v348 = 1
bs_v362 = bs_smoothy.new(1)

function bs_v370(arg_497_0, arg_497_1, arg_497_2)
	if bs_v196[arg_497_0] == nil then
		bs_v196[arg_497_0] = arg_497_1
	end

	bs_v196[arg_497_0] = bs_v196[arg_497_0] + (arg_497_1 - bs_v196[arg_497_0]) * arg_497_2

	return bs_v196[arg_497_0]
end

function bs_v380(arg_498_0, arg_498_1, arg_498_2)
	arg_498_2 = math.max(0, math.min(1, arg_498_2))

	return color(math.floor(arg_498_0.r + (arg_498_1.r - arg_498_0.r) * arg_498_2), math.floor(arg_498_0.g + (arg_498_1.g - arg_498_0.g) * arg_498_2), math.floor(arg_498_0.b + (arg_498_1.b - arg_498_0.b) * arg_498_2), math.floor(arg_498_0.a + (arg_498_1.a - arg_498_0.a) * arg_498_2))
end

function bs_v389(arg_499_0)
	if not arg_499_0 then
		return false
	end

	local var_499_0 = arg_499_0:get_player_weapon()

	if not var_499_0 then
		return false
	end

	local var_499_1 = var_499_0:get_weapon_info()

	if not var_499_1 or var_499_1.weapon_type ~= 9 then
		return false
	end

	return true
end

bs_v397 = {
	pulse = 0,
	scope = 0,
	dt = {
		active = 0,
		alpha = 0,
		last_text = "",
		adder = 0,
		fraction = 0,
		recharge = {
			0,
			0
		}
	},
	hs = {
		active = 0,
		alpha = 0,
		last_text = "",
		adder = 0,
		fraction = 0,
		inactive = {
			0,
			0,
			0
		}
	},
	fs = {
		fraction = 0,
		alpha = 0,
		last_text = "",
		adder = 0,
		disabled = {
			0,
			0,
			0
		}
	},
	state = {
		fraction = 0
	},
	hc = {
		fraction = 0
	},
	star = {
		alpha = 1
	}
}
bs_v405 = 0

function bs_v413(arg_500_0, arg_500_1, arg_500_2, arg_500_3, arg_500_4)
	local var_500_0 = ""
	local var_500_1 = arg_500_0:len()

	for iter_500_0 = 1, var_500_1 do
		local var_500_2 = arg_500_4 and 1 - arg_500_3 - (var_500_1 - iter_500_0) / (var_500_1 - 1) + (1 - arg_500_3) or iter_500_0 - arg_500_3 * var_500_1
		local var_500_3 = math.max(0, math.min(1, var_500_2))
		local var_500_4 = bs_v380(arg_500_1, arg_500_2, var_500_3)
		local var_500_5 = string.format("%02x%02x%02x%02x", var_500_4.r, var_500_4.g, var_500_4.b, var_500_4.a)
		local var_500_6 = ("\a%s%s"):format(var_500_5, arg_500_0:sub(iter_500_0, iter_500_0))

		var_500_0 = var_500_0 .. var_500_6
	end

	return var_500_0
end

function bs_v420(arg_501_0, arg_501_1, arg_501_2, arg_501_3)
	bs_v1666 = math.max(0.001, arg_501_2)
	bs_v405 = bs_v405 + bs_v1666
	bs_v1679 = bs_watermark_pos.position
	bs_v1681 = arg_501_0.m_col_accent and arg_501_0.m_col_accent:get() or color(200, 200, 210, 255)
	bs_v1680 = color(bs_v1681.r, bs_v1681.g, bs_v1681.b, 255)
	bs_v1682 = 0.07
	bs_v1683 = 0.055
	bs_v1684 = bs_get_font(arg_501_0)
	bs_v1557 = bs_v1684 == 1
	bs_v1558 = bs_v1684 == 2
	bs_v1559 = bs_v1558 and string.upper or string.lower

	function bs_v1560(arg_502_0)
		return bs_v1559(arg_502_0)
	end

	bs_v1561 = bs_v1557 and " " or "  "
	bs_v1562 = vector()
	bs_v1563 = arg_501_1.m_bIsScoped == true
	bs_v397.scope = math.max(0, math.min(1, bs_v397.scope + (bs_v1563 and bs_v1666 * 3.5 or -bs_v1666 * 3.5)))
	bs_v1564 = bs_easing.quad_in_out(bs_v397.scope, 0, 1, 1)
	bs_v397.star.alpha = math.max(0, math.min(1, bs_v397.star.alpha + (bs_v1563 and -bs_v1666 * 4 or bs_v1666 * 4)))
	bs_v1565 = bs_easing.quad_in_out(bs_v397.star.alpha, 0, 1, 1)

	if bs_v397.scope > 0.99 then
		bs_v397.pulse = bs_v397.pulse + bs_v1666 * 4
	else
		bs_v397.pulse = 0
	end

	bs_v1566 = 1

	if bs_v397.pulse > 0 then
		bs_v1566 = 0.5 + 0.5 * math.abs(math.sin(bs_v397.pulse))
	end

	bs_v1571 = bs_v1560("bluesense")
	bs_v1577 = arg_501_0.col_wave and arg_501_0.col_wave:get() or color(255, 255, 255, 255)
	bs_v1587 = (math.sin(globals.realtime * 1.6) + 1) * 0.5 * 1.4 - 0.2
	bs_v1592 = 0
	bs_v1597 = {}

	for iter_501_0 = 1, #bs_v1571 do
		bs_v1626 = bs_v1571:sub(iter_501_0, iter_501_0)
		bs_v1632 = render.measure_text(bs_v1684, nil, bs_v1626).x
		bs_v1637 = bs_v1558 and 2 or 0
		bs_v1597[iter_501_0] = {
			char = bs_v1626,
			w = bs_v1632,
			gap = bs_v1637
		}
		bs_v1592 = bs_v1592 + bs_v1632 + (iter_501_0 < #bs_v1571 and bs_v1637 or 0)
	end

	bs_v1602 = render.measure_text(bs_v1684, nil, bs_v1571).y
	bs_v1607 = vector(bs_v1592, bs_v1602)
	bs_v1612 = vector(math.floor(-(bs_v1607.x / 2) * (1 - bs_v1564) + 8 * bs_v1564))

	if arg_501_0.glow and arg_501_0.glow:get() then
		bs_v1625 = arg_501_0.glow_color and arg_501_0.glow_color:get() or bs_v1680

		render.rect(bs_v1679 + bs_v1612 + vector(1, 6), bs_v1679 + bs_v1612 + bs_v1607 + vector(1, 5) - vector(2, 10), color(bs_v1625.r, bs_v1625.g, bs_v1625.b, math.floor(70 * bs_v1566)), 5)
		render.shadow(bs_v1679 + bs_v1612 + vector(5, 6), bs_v1679 + bs_v1612 + bs_v1607 + vector(5, 5) - vector(10, 10), color(bs_v1625.r, bs_v1625.g, bs_v1625.b, math.floor(bs_v1625.a * bs_v1566)), nil, nil, 5)
	end

	bs_v1624 = 0

	for iter_501_1 = 1, #bs_v1597 do
		bs_v1649 = (iter_501_1 - 1) / math.max(#bs_v1571 - 1, 1)
		bs_v1652 = math.abs(bs_v1649 - bs_v1587)
		bs_v1657 = math.max(0, 1 - bs_v1652 / 0.12)
		bs_v1656 = bs_v1657 * bs_v1657 * bs_v1657 * bs_v1657
		bs_v1662 = math.max(0, 1 - bs_v1652 / 0.5)
		bs_v1661 = bs_v1662 * bs_v1662 * 0.35
		bs_v1665 = math.min(1, bs_v1656 + bs_v1661)
		bs_v1669 = math.floor(bs_v1680.r + (bs_v1577.r - bs_v1680.r) * bs_v1665)
		bs_v1672 = math.floor(bs_v1680.g + (bs_v1577.g - bs_v1680.g) * bs_v1665)
		bs_v1674 = math.floor(bs_v1680.b + (bs_v1577.b - bs_v1680.b) * bs_v1665)
		bs_v1676 = color(bs_v1669, bs_v1672, bs_v1674, math.floor(255 * bs_v1566))

		render.text(bs_v1684, bs_v1679 + bs_v1612 + vector(bs_v1624, 0), bs_v1676, nil, bs_v1597[iter_501_1].char)

		bs_v1624 = bs_v1624 + bs_v1597[iter_501_1].w + bs_v1597[iter_501_1].gap
	end

	bs_v1562.y = bs_v1562.y + (bs_v1607.y - 2)
	bs_v1631 = ui.get_alpha() > 0
	bs_v1636 = false

	if bs_v1631 and bs_tab_dummy then
		bs_v1641, bs_v1645 = pcall(function()
			return bs_tab_dummy:get()
		end)
		bs_v1636 = bs_v1641 and bs_v1645 == 2
	end

	if bs_v1636 then
		bs_watermark_pos:update(vector(bs_v1607.x, bs_v1607.y + 10))
	end

	if arg_501_0.m_show_state and arg_501_0.m_show_state:get() then
		bs_v1570 = false

		pcall(function()
			bs_v1570 = bs_config.antiaim.misc.fake_duck:get()
		end)

		bs_v1576 = nil

		if bs_safe_head.active then
			bs_v1575 = "safehead"
		elseif bs_v1570 then
			bs_v1575 = "fakeduck"
		else
			bs_v1582 = bs_get_state.visual(bs_legit_aa.is_working) or bs_get_state.get(bs_legit_aa.is_working) or "standing"
			bs_v1575 = ({
				running = "moving",
				["legit aa"] = "legit",
				air = "air",
				["air crouching"] = "air crouch",
				slowing = "slowwalk",
				sneaking = "crouch",
				crouching = "crouch",
				standing = "standing"
			})[bs_v1582] or "standing"
		end

		bs_v1581 = bs_v1560(bs_v1575)
		bs_v1586 = render.measure_text(bs_v1684, nil, bs_v1581)
		bs_v1591 = "·"
		bs_v1596 = "·"
		bs_v1601 = render.measure_text(bs_v1684, nil, bs_v1591)
		bs_v397.state.fraction = bs_easing.linear(bs_v1666, bs_v397.state.fraction, bs_v1586.x + 3 - bs_v397.state.fraction, bs_v1683)
		bs_v1606 = math.floor(bs_v397.state.fraction)
		bs_v1611 = vector(math.floor(-(bs_v1586.x / 2) * (1 - bs_v1564) * (math.max(1, bs_v1606) / (bs_v1586.x + 3)) + (bs_v1601.x + 2) * bs_v1564 + 8 * bs_v1564 + 0.5))

		render.push_clip_rect(bs_v1679 + bs_v1611 + bs_v1562, bs_v1679 + bs_v1611 + bs_v1562 + vector(bs_v1606, bs_v1586.y + 5))
		render.text(bs_v1684, bs_v1679 + bs_v1611 + bs_v1562, color(255, 255, 255, math.floor(255 * bs_v1566)), nil, bs_v1581)
		render.pop_clip_rect()

		bs_v1618 = vector(math.floor((-bs_v1606 / 2 - bs_v1601.x - 1) * (1 - bs_v1564) + 8 * bs_v1564 + 0.6))
		bs_v1623 = vector(math.floor(bs_v1606 / 2 * (1 + bs_v1564) + (bs_v1601.x + 1) * bs_v1564 + 8 * bs_v1564 + 0.6))
		bs_v1630 = color(255, 255, 255, math.floor(255 * bs_v1566))

		render.text(bs_v1684, bs_v1679 + bs_v1618 + bs_v1562, bs_v1630, nil, bs_v1591)
		render.text(bs_v1684, bs_v1679 + bs_v1623 + bs_v1562, bs_v1630, nil, bs_v1596)

		bs_v1562.y = bs_v1562.y + (bs_v1586.y - 2)
	end

	if arg_501_0.m_show_dt and arg_501_0.m_show_dt:get() then
		bs_v1569 = rage.exploit:get() == 1
		bs_v1574, bs_v1580 = pcall(function()
			return bs_config.rage.main.double_tap:get()
		end)
		bs_v1585 = bs_v1574 and bs_v1580 and not bs_auto_hide_shots.is_active
		bs_v397.dt.alpha = math.max(0, math.min(1, bs_v397.dt.alpha + (bs_v1585 and bs_v1666 * 2.5 or -bs_v1666 * 2.5)))
		bs_v1590 = bs_v397.dt.alpha
		bs_v1595 = 0
		bs_v1600 = bs_v1560("dt")
		bs_v1605 = render.measure_text(bs_v1684, nil, bs_v1600)
		bs_v1610 = ""

		if bs_v1590 > 0 then
			if bs_v1585 and bs_v1590 > 0.1 then
				bs_v1595 = bs_v1595 + bs_v1605.x
			end

			bs_v397.dt.recharge[1] = math.max(0, math.min(1, bs_v397.dt.recharge[1] + (bs_v1590 == 1 and bs_v1569 and bs_v1666 * 2.5 or -bs_v1666 * 2.5)))
			bs_v1617 = bs_v397.dt.recharge[1]
			bs_v397.dt.recharge[2] = math.max(0, math.min(1, bs_v397.dt.recharge[2] + (bs_v1617 == 1 and bs_v1666 * 3.5 or -bs_v1666 * 3.5)))
			bs_v1622 = bs_v397.dt.recharge[2]
			bs_v1629 = bs_v1560("charging")
			bs_v1635 = bs_v413(bs_v1629, color(150, 220, 160, math.floor(255 * bs_v1566)), color(255, 66, 66, math.floor(255 * bs_v1566)), bs_v1617, true)
			bs_v1640 = render.measure_text(bs_v1684, nil, bs_v1561 .. bs_v1629)
			bs_v397.dt.active = math.max(0, math.min(1, bs_v397.dt.active + (bs_v1622 == 1 and bs_v1666 * 1.5 or -bs_v1666 * 3)))
			bs_v1644 = bs_v397.dt.active
			bs_v1648 = bs_v1560("charged")
			bs_v1651 = bs_v413(bs_v1648, color(150, 220, 160, math.floor(255 * bs_v1566)), color(255, 255, 255, math.floor(50 * bs_v1566)), bs_v1644, true)
			bs_v1655 = render.measure_text(bs_v1684, nil, bs_v1561 .. bs_v1648)

			if bs_v1585 and bs_v1590 > 0.95 then
				bs_v1595 = bs_v1595 + bs_v1640.x
			end

			if bs_v1622 < 1 then
				bs_v1610 = bs_v1561 .. bs_v1635
			end

			if bs_v1622 > 0 then
				bs_v1595 = bs_v1605.x
			end

			if bs_v1622 > 0.5 then
				bs_v1610 = bs_v1561 .. bs_v1651
			end

			if bs_v1622 == 1 then
				bs_v1595 = bs_v1595 + bs_v1655.x
			end

			if bs_v1585 then
				bs_v397.dt.last_text = bs_v1610
			end

			if not bs_v1585 or bs_v1590 == 0 then
				bs_v1595 = 0
			end

			bs_v397.dt.fraction = bs_easing.linear(bs_v1666, bs_v397.dt.fraction, bs_v1595 - bs_v397.dt.fraction, bs_v1682)
			bs_v1660 = math.floor(bs_v397.dt.fraction)
			bs_v1668 = string.format("\a%02x%02x%02x%02x", 255, 255, 255, math.floor(255 * bs_v1566)) .. bs_v1600 .. bs_v397.dt.last_text
			bs_v1671 = render.measure_text(bs_v1684, nil, bs_v1600 .. string.gsub(bs_v397.dt.last_text, "\a%x%x%x%x%x%x%x%x", ""))
			bs_v1673 = vector(math.floor(-(bs_v1671.x / 2) * (1 - bs_v1564) * (bs_v1660 / math.max(1, bs_v1671.x)) + 8 * bs_v1564))

			render.push_clip_rect(bs_v1679 + bs_v1673 + bs_v1562 + vector(0, 2), bs_v1679 + bs_v1673 + bs_v1562 - vector(0, 1) + vector(bs_v1660, bs_v1671.y + 5))
			render.text(bs_v1684, bs_v1679 + bs_v1673 + bs_v1562, color(255, 255, 255, 255), nil, bs_v1668)
			render.pop_clip_rect()
		end

		bs_v397.dt.adder = math.max(0, math.min(1, bs_v397.dt.adder + (bs_v1585 and bs_v1666 * 5.5 or -bs_v1666 * 5.5)))
		bs_v1616 = bs_easing.quad_out(bs_v397.dt.adder, 0, 1, 1)
		bs_v1562.y = bs_v1562.y + (bs_v1605.y - 2) * bs_v1616
	end

	if arg_501_0.m_show_hs and arg_501_0.m_show_hs:get() then
		bs_v1568, bs_v1573 = pcall(function()
			return bs_config.rage.main.hide_shots:get()
		end)
		bs_v1579 = bs_auto_hide_shots.is_active
		bs_v1584 = bs_v1568 and bs_v1573 or bs_v1579
		bs_v1589 = false

		pcall(function()
			bs_v1589 = bs_config.rage.main.double_tap:get()
		end)

		bs_v397.hs.alpha = math.max(0, math.min(1, bs_v397.hs.alpha + (bs_v1584 and bs_v1666 * 2.5 or -bs_v1666 * 2.5)))
		bs_v1594 = bs_v397.hs.alpha
		bs_v1599 = 0
		bs_v1604 = bs_v1560("hide")
		bs_v1609 = render.measure_text(bs_v1684, nil, bs_v1604)
		bs_v1615 = ""

		if bs_v1594 > 0 then
			if bs_v1584 and bs_v1594 > 0.1 then
				bs_v1599 = bs_v1599 + bs_v1609.x
			end

			bs_v397.hs.inactive[1] = math.max(0, math.min(1, bs_v397.hs.inactive[1] + (bs_v1589 and not bs_v1579 and bs_v1666 * 3.5 or -bs_v1666 * 3.5)))
			bs_v1621 = bs_v397.hs.inactive[1]
			bs_v397.hs.inactive[2] = math.max(0, math.min(1, bs_v397.hs.inactive[2] + (bs_v1621 == 1 and bs_v1666 * 3.5 or -bs_v1666 * 3.5)))
			bs_v1628 = bs_v397.hs.inactive[2]
			bs_v397.hs.inactive[3] = math.max(0, math.min(1, bs_v397.hs.inactive[3] + (bs_v1594 == 1 and bs_v1628 > 0.1 and bs_v1666 * 1.5 or -bs_v1666 * 4)))
			bs_v1634 = bs_v397.hs.inactive[3]
			bs_v1639 = bs_v1560("inactive")
			bs_v1643 = bs_v413(bs_v1639, color(242, 189, 75, math.floor(255 * bs_v1566)), color(0, 0, 0, 0), bs_v1634, true)
			bs_v1647 = render.measure_text(bs_v1684, nil, bs_v1561 .. bs_v1639)
			bs_v397.hs.active = math.max(0, math.min(1, bs_v397.hs.active + (bs_v1594 == 1 and (bs_v1579 or not bs_v1589) and bs_v1666 * 1.5 or -bs_v1666 * 4)))
			bs_v1650 = bs_v397.hs.active
			bs_v1654 = bs_v1579 and "auto" or "active"
			bs_v1659 = bs_v1560(bs_v1654)
			bs_v1664 = bs_v413(bs_v1659, color(112, 161, 224, math.floor(255 * bs_v1566)), color(0, 0, 0, 0), bs_v1650, true)
			bs_v1667 = render.measure_text(bs_v1684, nil, bs_v1561 .. bs_v1659)

			if bs_v1584 and bs_v1594 > 0.95 and bs_v1628 ~= 1 then
				bs_v1615 = bs_v1561 .. bs_v1664
				bs_v1599 = bs_v1599 + bs_v1667.x
			end

			if bs_v1584 and bs_v1594 > 0.95 and bs_v1621 > 0 then
				bs_v1599 = bs_v1609.x
			end

			if bs_v1584 and bs_v1594 > 0.95 and bs_v1628 > 0 then
				bs_v1615 = bs_v1561 .. bs_v1643
			end

			if bs_v1584 and bs_v1594 > 0.95 and bs_v1621 == 1 then
				bs_v1599 = bs_v1599 + bs_v1647.x
			end

			if bs_v1584 then
				bs_v397.hs.last_text = bs_v1615
			end

			if not bs_v1584 or bs_v1594 == 0 then
				bs_v1599 = 0
			end

			bs_v397.hs.fraction = bs_easing.linear(bs_v1666, bs_v397.hs.fraction, bs_v1599 - bs_v397.hs.fraction, bs_v1682)
			bs_v1670 = math.floor(bs_v397.hs.fraction)
			bs_v1675 = string.format("\a%02x%02x%02x%02x", 255, 255, 255, math.floor(255 * bs_v1566)) .. bs_v1604 .. bs_v397.hs.last_text
			bs_v1677 = render.measure_text(bs_v1684, nil, bs_v1604 .. string.gsub(bs_v397.hs.last_text, "\a%x%x%x%x%x%x%x%x", ""))
			bs_v1678 = vector(math.floor(-(bs_v1677.x / 2) * (1 - bs_v1564) * (bs_v1670 / math.max(1, bs_v1677.x)) + 8 * bs_v1564))

			render.push_clip_rect(bs_v1679 + bs_v1678 + bs_v1562 + vector(0, 2), bs_v1679 + bs_v1678 + bs_v1562 - vector(0, 1) + vector(bs_v1670, bs_v1677.y + 5))
			render.text(bs_v1684, bs_v1679 + bs_v1678 + bs_v1562, color(255, 255, 255, 255), nil, bs_v1675)
			render.pop_clip_rect()
		end

		bs_v397.hs.adder = math.max(0, math.min(1, bs_v397.hs.adder + (bs_v1584 and bs_v1666 * 5.5 or -bs_v1666 * 5.5)))
		bs_v1620 = bs_easing.quad_out(bs_v397.hs.adder, 0, 1, 1)
		bs_v1562.y = bs_v1562.y + (bs_v1609.y - 2) * bs_v1620
	end

	if arg_501_0.m_show_fs and arg_501_0.m_show_fs:get() then
		bs_v1567 = bs_freestanding.think()
		bs_v1572 = false
		bs_v397.fs.alpha = math.max(0, math.min(1, bs_v397.fs.alpha + (bs_v1567 and bs_v1666 * 2.5 or -bs_v1666 * 2.5)))
		bs_v1578 = bs_v397.fs.alpha
		bs_v1583 = 0
		bs_v1588 = bs_v1560("freestand")
		bs_v1593 = render.measure_text(bs_v1684, nil, bs_v1588)
		bs_v1598 = bs_v1560("fs")
		bs_v1603 = render.measure_text(bs_v1684, nil, bs_v1598)
		bs_v1608 = ""

		if bs_v1578 > 0 then
			if bs_v1567 and bs_v1578 > 0.1 then
				bs_v1583 = bs_v1583 + bs_v1593.x
			end

			bs_v397.fs.disabled[1] = math.max(0, math.min(1, bs_v397.fs.disabled[1] + (bs_v1572 and bs_v1666 * 3.3 or -bs_v1666 * 3)))
			bs_v1614 = bs_v397.fs.disabled[1]
			bs_v397.fs.disabled[2] = math.max(0, math.min(1, bs_v397.fs.disabled[2] + (bs_v1614 == 1 and bs_v1666 * 2.5 or -bs_v1666 * 5)))
			bs_v1619 = bs_v397.fs.disabled[2]
			bs_v397.fs.disabled[3] = math.max(0, math.min(1, bs_v397.fs.disabled[3] + (bs_v1578 == 1 and bs_v1619 == 1 and bs_v1666 * 1.5 or -bs_v1666 * 4)))
			bs_v1627 = bs_v397.fs.disabled[3]
			bs_v1633 = bs_v1560("disabled")
			bs_v1638 = bs_v413(bs_v1633, color(120, 120, 120, math.floor(255 * bs_v1566)), color(0, 0, 0, 0), bs_v1627, true)
			bs_v1642 = render.measure_text(bs_v1684, nil, bs_v1561 .. bs_v1633)

			if bs_v1614 ~= 0 then
				bs_v1583 = bs_v1603.x - 7
			end

			if bs_v1614 > 0.5 then
				bs_v1588 = bs_v1598
			end

			if bs_v1614 == 1 then
				bs_v1583 = bs_v1603.x
			end

			if bs_v1619 > 0 then
				bs_v1588 = bs_v1588 .. bs_v1561 .. bs_v1638
			end

			if bs_v1578 > 0.95 and bs_v1619 > 0.95 then
				bs_v1583 = bs_v1583 + bs_v1642.x
			end

			if bs_v1567 then
				bs_v397.fs.last_text = bs_v1588 .. bs_v1608
			end

			if not bs_v1567 or bs_v1578 == 0 then
				bs_v1583 = 0
			end

			bs_v397.fs.fraction = bs_easing.linear(bs_v1666, bs_v397.fs.fraction, bs_v1583 - bs_v397.fs.fraction, bs_v1682)
			bs_v1646 = math.floor(bs_v397.fs.fraction)
			bs_v1653 = string.format("\a%02x%02x%02x%02x", 255, 255, 255, math.floor(255 * bs_v1566)) .. bs_v397.fs.last_text
			bs_v1658 = render.measure_text(bs_v1684, nil, string.gsub(bs_v397.fs.last_text, "\a%x%x%x%x%x%x%x%x", ""))
			bs_v1663 = vector(math.floor(-(bs_v1658.x / 2) * (1 - bs_v1564) * (bs_v1646 / math.max(1, bs_v1658.x)) + 8 * bs_v1564))

			render.push_clip_rect(bs_v1679 + bs_v1663 + bs_v1562 + vector(0, 2), bs_v1679 + bs_v1663 + bs_v1562 - vector(0, 1) + vector(bs_v1646, bs_v1658.y + 5))
			render.text(bs_v1684, bs_v1679 + bs_v1663 + bs_v1562, color(255, 255, 255, 255), nil, bs_v1653)
			render.pop_clip_rect()
		end

		bs_v397.fs.adder = math.max(0, math.min(1, bs_v397.fs.adder + (bs_v1567 and bs_v1666 * 5.5 or -bs_v1666 * 5.5)))
		bs_v1613 = bs_easing.quad_out(bs_v397.fs.adder, 0, 1, 1)
		bs_v1562.y = bs_v1562.y + (bs_v1593.y - 2) * bs_v1613
	end

	if arg_501_0.m_show_hc and arg_501_0.m_show_hc:get() then
		local hc_v = bs_active_hc_value or 0
		local hc_st = bs_active_hc_state or (bs_get_state.visual(bs_legit_aa.is_working) or bs_get_state.get(bs_legit_aa.is_working) or "standing")
		local hc_txt = hc_v > 0 and ("HC: SET " .. hc_v .. " (" .. hc_st .. ")") or "HC: OFF"
		local hc_col = arg_501_0.hc_col and arg_501_0.hc_col:get() or color(200, 200, 210, 255)
		local hc_ms = render.measure_text(bs_v1684, nil, hc_txt)
		local hc_dot = render.measure_text(bs_v1684, nil, "·")
		bs_v397.hc.fraction = bs_easing.linear(bs_v1666, bs_v397.hc.fraction, hc_ms.x + 3 - bs_v397.hc.fraction, bs_v1683)
		local hc_fr = math.floor(bs_v397.hc.fraction)
		local hc_pos = vector(math.floor(-(hc_ms.x / 2) * (1 - bs_v1564) * (math.max(1, hc_fr) / (hc_ms.x + 3)) + (hc_dot.x + 2) * bs_v1564 + 8 * bs_v1564 + 0.5))

		render.push_clip_rect(bs_v1679 + hc_pos + bs_v1562, bs_v1679 + hc_pos + bs_v1562 + vector(hc_fr, hc_ms.y + 5))
		render.text(bs_v1684, bs_v1679 + hc_pos + bs_v1562, color(hc_col.r, hc_col.g, hc_col.b, math.floor(255 * bs_v1566)), nil, hc_txt)
		render.pop_clip_rect()

		local hc_left = vector(math.floor((-hc_fr / 2 - hc_dot.x - 1) * (1 - bs_v1564) + 8 * bs_v1564 + 0.6))
		local hc_right = vector(math.floor(hc_fr / 2 * (1 + bs_v1564) + (hc_dot.x + 1) * bs_v1564 + 8 * bs_v1564 + 0.6))
		render.text(bs_v1684, bs_v1679 + hc_left + bs_v1562, color(255, 255, 255, math.floor(255 * bs_v1566)), nil, "·")
		render.text(bs_v1684, bs_v1679 + hc_right + bs_v1562, color(255, 255, 255, math.floor(255 * bs_v1566)), nil, "·")

		bs_v1562.y = bs_v1562.y + (hc_ms.y - 2)
	end
end

bs_v426 = 0

events.aim_fire(function(arg_508_0)
	local var_508_0 = entity.get_local_player()

	if not var_508_0 or not var_508_0:is_alive() then
		return
	end

	bs_v426 = globals.realtime
end)
events.createmove(function()
	local var_509_0 = bs_menu.visuals.silent_view

	if not var_509_0 or not var_509_0.switch:get() then
		return
	end

	local var_509_1 = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Silent Aim")

	if var_509_1 then
		var_509_1:set(true)
	end
end)
events.aim_fire(function(arg_510_0)
	local var_510_0 = bs_menu.visuals.silent_view

	if not var_510_0 or not var_510_0.switch:get() then
		return
	end

	local var_510_1 = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Silent Aim")

	if not var_510_1 then
		return
	end

	local var_510_2 = entity.get_local_player()

	if not var_510_2 or not var_510_2:is_alive() then
		return
	end

	local var_510_3 = render.camera_position()
	local var_510_4 = render.camera_angles()
	local var_510_5 = (arg_510_0.aim - var_510_3):angles()
	local var_510_6 = var_510_4.x - var_510_5.x
	local var_510_7 = var_510_4.y - var_510_5.y

	while var_510_7 > 180 do
		var_510_7 = var_510_7 - 360
	end

	while var_510_7 < -180 do
		var_510_7 = var_510_7 + 360
	end

	if math.sqrt(var_510_6^2 + var_510_7^2) < var_510_0.fov:get() then
		var_510_1:set(false)
		render.camera_angles(var_510_5)
	end
end)

bs_v431 = 0
bs_v435 = 0

events.render(function()
	local var_511_0 = bs_menu.visuals.silent_view

	if not var_511_0 or not var_511_0.switch:get() then
		return
	end

	local var_511_1 = var_511_0.fov:get()

	if var_511_1 ~= bs_v431 then
		bs_v431 = var_511_1
		bs_v435 = globals.realtime
	end

	local var_511_2 = globals.realtime - bs_v435

	if var_511_2 > 1.5 then
		return
	end

	if not (ui.get_alpha() > 0) then
		return
	end

	local var_511_3 = false

	if bs_tab_dummy then
		local var_511_4, var_511_5 = pcall(function()
			return bs_tab_dummy:get()
		end)

		var_511_3 = var_511_4 and var_511_5 == 2
	end

	if not var_511_3 then
		return
	end

	local var_511_6 = entity.get_local_player()

	if not var_511_6 or not var_511_6:is_alive() then
		return
	end

	local var_511_7 = render.screen_size()
	local var_511_8 = vector(var_511_7.x / 2, var_511_7.y / 2)
	local var_511_9 = var_511_0.fov:get()
	local var_511_10 = 90
	local var_511_11, var_511_12 = pcall(function()
		return ui.find("Visuals", "World", "Main", "Field of View"):get()
	end)

	if var_511_11 and var_511_12 ~= 0 then
		var_511_10 = var_511_12
	end

	local var_511_13 = var_511_9 / var_511_10 * (var_511_7.y / 2)
	local var_511_14 = globals.realtime
	local var_511_15 = math.sin(var_511_14 * 3) * 0.5 + 0.5
	local var_511_16 = color(255, 255, 255, 255)

	pcall(function()
		var_511_16 = bs_v479:get()
	end)

	local var_511_17 = 1

	if var_511_2 > 1 then
		var_511_17 = math.max(0, 1 - (var_511_2 - 1) / 0.5)
	end

	local var_511_18 = color(var_511_16.r, var_511_16.g, var_511_16.b, (60 + 100 * var_511_15) * var_511_17)
	local var_511_19 = 200
	local var_511_20 = math.pi * 2 / var_511_19

	for iter_511_0 = 0, var_511_19 - 1 do
		local var_511_21 = iter_511_0 * var_511_20
		local var_511_22 = (iter_511_0 + 1) * var_511_20
		local var_511_23 = var_511_8 + vector(math.cos(var_511_21) * var_511_13, math.sin(var_511_21) * var_511_13)
		local var_511_24 = var_511_8 + vector(math.cos(var_511_22) * var_511_13, math.sin(var_511_22) * var_511_13)

		render.line(var_511_23, var_511_24, var_511_18)
	end
end)

bs_v439 = render.load_font("Verdana Bold", 11, "ab")
bs_v443 = render.load_font("Verdana", 10, "a")
bs_v447 = {
	bar_frac = 0,
	bar_alpha = 0,
	title_a = 0,
	gap = 0,
	dt_ticks = 0,
	scope = 0
}

function bs_v451(arg_515_0, arg_515_1, arg_515_2)
	bs_v1706 = bs_watermark_pos.position
	bs_v1719, bs_v1731, bs_v1749, bs_v1754 = (function()
		local var_516_0 = arg_515_0.new_title_col:get()

		return var_516_0.r, var_516_0.g, var_516_0.b, var_516_0.a
	end)()
	bs_v1755, bs_v1756, bs_v1685, bs_v1686 = (function()
		local var_517_0 = arg_515_0.new_grad_col:get()

		return var_517_0.r, var_517_0.g, var_517_0.b, var_517_0.a
	end)()
	bs_v1687, bs_v1688, bs_v1689, bs_v1690 = (function()
		local var_518_0 = arg_515_0.new_shot_col:get()

		return var_518_0.r, var_518_0.g, var_518_0.b, var_518_0.a
	end)()
	bs_v1691, bs_v1692, bs_v1693, bs_v1694 = (function()
		local var_519_0 = arg_515_0.new_state_col:get()

		return var_519_0.r, var_519_0.g, var_519_0.b, var_519_0.a
	end)()
	bs_v1695, bs_v1696, bs_v1697, bs_v1698 = (function()
		local var_520_0 = arg_515_0.new_flags_col:get()

		return var_520_0.r, var_520_0.g, var_520_0.b, var_520_0.a
	end)()
	bs_v1699 = arg_515_1.m_bIsScoped == true
	bs_v447.scope = bs_v447.scope + ((bs_v1699 and 1 or 0) - bs_v447.scope) * (1 - math.exp(-arg_515_2 * 12))
	bs_v447.title_a = math.max(0, math.min(1, bs_v447.title_a + arg_515_2 * 3))
	bs_v447.gap = bs_v447.gap + ((bs_v1699 and 1 or 0) - bs_v447.gap) * (1 - math.exp(-arg_515_2 * 12))
	bs_v447.bar_alpha = bs_v447.bar_alpha + (1 - bs_v447.bar_alpha) * (1 - math.exp(-arg_515_2 * 8))
	bs_v1700 = bs_v447.scope
	bs_v1701 = bs_v447.title_a
	bs_v1702 = math.floor(bs_v1706.x + 22 * bs_v1700 + 0.5)
	bs_v1704 = math.floor(bs_v1706.y + 0.5)
	bs_v1705 = bs_get_state.get and bs_get_state.get(bs_legit_aa.is_working) or "standing"

	if (arg_515_0.new_show_state == nil or arg_515_0.new_show_state:get()) and bs_v1705 then
		bs_v1708 = bs_v1705:upper()
		bs_v1710 = render.measure_text(2, nil, bs_v1708).x
		bs_v1712 = math.floor(bs_v1702 - bs_v1710 / 2 * (1 - bs_v1700) + 0.5)

		render.text(2, vector(bs_v1712, bs_v1704 - 1), color(bs_v1691, bs_v1692, bs_v1693, math.floor(bs_v1694 * bs_v1701)), nil, bs_v1708)

		bs_v1704 = bs_v1704 + 8
	end

	bs_v1707 = "bluesense"
	bs_v1709 = render.measure_text(bs_v439, nil, bs_v1707)
	bs_v1711 = bs_v1709.x
	bs_v1713 = bs_v1709.y
	bs_v1714 = math.floor(40 * bs_v1701)
	bs_v1715 = math.floor(bs_v1702 + bs_v1700 - bs_v1711 / 2 * (1 - bs_v1700) + 0.5)

	render.text(bs_v439, vector(bs_v1715 + 1, bs_v1704 + 1), color(0, 0, 0, bs_v1714), nil, bs_v1707)
	render.text(bs_v439, vector(bs_v1715, bs_v1704), color(bs_v1719, bs_v1731, bs_v1749, math.floor(bs_v1754 * bs_v1701)), nil, bs_v1707)

	bs_v1716 = bs_v1704 + bs_v1713 + 3
	bs_v1717 = arg_515_1.m_flPoseParameter and arg_515_1.m_flPoseParameter[11] or 0
	bs_v1718 = math.abs(bs_v1717 * 120 - 60)
	bs_v1720 = math.max(0, math.min(1, bs_v1718 / 58))
	bs_v447.bar_frac = bs_v447.bar_frac + (bs_v1720 - bs_v447.bar_frac) * (1 - math.exp(-arg_515_2 * 10))
	bs_v1721 = bs_v1711 / 2 + 15
	bs_v1722 = math.max(1, math.floor(bs_v1721 * bs_v447.bar_frac))
	bs_v1723 = globals.realtime - bs_v426
	bs_v1724 = math.max(0, 1 - bs_v1723 / 0.5)
	bs_v1725 = math.floor(bs_v1755 + (bs_v1687 - bs_v1755) * bs_v1724)
	bs_v1726 = math.floor(bs_v1756 + (bs_v1688 - bs_v1756) * bs_v1724)
	bs_v1727 = math.floor(bs_v1685 + (bs_v1689 - bs_v1685) * bs_v1724)
	bs_v1728 = math.floor(bs_v1686 * bs_v1701 * bs_v447.bar_alpha)

	if bs_v1722 > 0 and bs_v1728 > 0 then
		bs_v1730 = bs_v1722 * (1 + 1.8 * bs_v1700)
		bs_v1733 = bs_v1722 * (1 - bs_v1700)
		bs_v1735 = color(bs_v1725, bs_v1726, bs_v1727, bs_v1728)
		bs_v1738 = color(bs_v1725, bs_v1726, bs_v1727, 0)

		render.gradient(vector(bs_v1702, bs_v1716), vector(bs_v1702 + bs_v1730, bs_v1716 + 1), bs_v1735, bs_v1738, bs_v1735, bs_v1738)

		if bs_v1733 > 1 then
			render.gradient(vector(bs_v1702 - bs_v1733, bs_v1716), vector(bs_v1702, bs_v1716 + 1), bs_v1738, bs_v1735, bs_v1738, bs_v1735)
		end
	end

	bs_v1703 = bs_v1716 + 2
	bs_v1729 = {}
	bs_v1732, bs_v1734 = pcall(function()
		return bs_config.rage.main.double_tap:get()
	end)

	if bs_v1732 and bs_v1734 and not bs_auto_hide_shots.is_active then
		bs_v1737 = rage.exploit:get() == 1
		bs_v1740 = 15
		bs_v1742 = bs_v1737 and bs_v1740 or 0
		bs_v447.dt_ticks = bs_v447.dt_ticks + (bs_v1742 - bs_v447.dt_ticks) * (1 - math.exp(-arg_515_2 * 10))
		bs_v1744 = math.floor(bs_v447.dt_ticks + 0.5)

		table.insert(bs_v1729, {
			n = string.format("DOUBLE TAP [%d]", bs_v1744),
			glow = not bs_v1737
		})
	else
		bs_v447.dt_ticks = 0
	end

	bs_v1736, bs_v1739 = pcall(function()
		return bs_config.rage.main.hide_shots:get()
	end)

	if bs_v1736 and bs_v1739 or bs_auto_hide_shots.is_active then
		table.insert(bs_v1729, {
			n = "HIDESHOTS"
		})
	end

	if bs_freestanding.think() then
		table.insert(bs_v1729, {
			n = "FREESTANDING"
		})
	end

	bs_v1741 = false
	bs_v1743, bs_v1745 = pcall(ui.get_binds)

	if bs_v1743 and bs_v1745 then
		for iter_515_0, iter_515_1 in ipairs(bs_v1745) do
			bs_v1753 = (iter_515_1.name or ""):lower()

			if iter_515_1.active and (bs_v1753:find("damage") or bs_v1753:find("min%.") or bs_v1753 == "min. damage") then
				bs_v1741 = true

				break
			end
		end
	end

	if not bs_v1741 then
		bs_v1746, bs_v1747 = pcall(function()
			return bs_config.rage.selection.minimum_damage_global:get()
		end)
		bs_v1741 = bs_v1746 and bs_v1747 == true
	end

	if bs_v1741 then
		table.insert(bs_v1729, {
			n = "DAMAGE"
		})
	end

	for iter_515_2, iter_515_3 in ipairs(bs_v1729) do
		bs_v1748 = iter_515_3.glow and 0.5 + 0.5 * math.abs(math.sin(globals.curtime * 3 + iter_515_2)) or 1
		bs_v1750 = math.floor(bs_v1698 * bs_v1701 * bs_v1748)
		bs_v1751 = render.measure_text(2, nil, iter_515_3.n).x
		bs_v1752 = math.floor(bs_v1702 - bs_v1751 / 2 * (1 - bs_v1700) + 0.5)

		render.text(2, vector(bs_v1752, bs_v1703), color(bs_v1695, bs_v1696, bs_v1697, bs_v1750), nil, iter_515_3.n)

		bs_v1703 = bs_v1703 + 8
	end

	if arg_515_0.new_show_hc == nil or arg_515_0.new_show_hc:get() then
		local hc_v = bs_active_hc_value or 0
		local hc_st = bs_active_hc_state or (bs_get_state.visual(bs_legit_aa.is_working) or bs_get_state.get(bs_legit_aa.is_working) or "standing")
		local hc_txt = hc_v > 0 and ("HC: SET " .. hc_v .. " (" .. hc_st .. ")") or "HC: OFF"
		local hc_col = arg_515_0.new_hc_col and arg_515_0.new_hc_col:get() or color(200, 200, 210, 255)
		local hc_ms = render.measure_text(2, nil, hc_txt)
		local hc_pos = math.floor(bs_v1702 - hc_ms.x / 2 * (1 - bs_v1700) + 0.5)

		render.text(2, vector(hc_pos, bs_v1703), color(hc_col.r, hc_col.g, hc_col.b, math.floor(hc_col.a * bs_v1701)), nil, hc_txt)
		bs_v1703 = bs_v1703 + 8
	end
end

events.render(function()
	bs_indicators.data = {}

	local var_524_0 = bs_menu.info.crosshair

	if not var_524_0 then
		return
	end

	if not var_524_0.enabled:get() then
		return
	end

	local var_524_1 = entity.get_local_player()

	if not var_524_1 or not var_524_1:is_alive() then
		return
	end

	local var_524_2, var_524_3 = pcall(function()
		return var_524_0.style:get()
	end)

	if var_524_2 and var_524_3 == "old" then
		bs_v451(var_524_0, var_524_1, globals.frametime)
	else
		bs_v420(var_524_0, var_524_1, globals.frametime, bs_blur_func())
	end
end)

bs_v758 = nil
bs_v3 = false
bs_v20 = 0
bs_v33 = 0
bs_v49 = 0
bs_v64 = false

events.net_update_end(function()
	local var_526_0, var_526_1 = pcall(function()
		return rage.exploit:get()
	end)

	bs_v3 = var_526_0 and var_526_1 == 1

	if not bs_v3 then
		bs_v64 = false
		bs_v49 = 0
	end
end)
events.createmove(function(arg_528_0)
	if not bs_v3 then
		bs_v64 = false

		return
	end

	local var_528_0 = entity.get_local_player()

	if not var_528_0 or not var_528_0:is_alive() then
		bs_v64 = false

		return
	end

	local var_528_1 = var_528_0.m_nTickBase
	local var_528_2 = globals.server_tick
	local var_528_3 = var_528_1 - bs_v20

	bs_v20 = math.max(var_528_1, bs_v20)

	if var_528_3 > 1 then
		bs_v33 = var_528_2 + 1
		bs_v49 = 0
	elseif var_528_3 < 0 then
		bs_v49 = var_528_2 - var_528_3 - 4
	elseif bs_v33 == var_528_2 then
		bs_v49 = var_528_2 + 1
	end

	bs_v64 = var_528_2 <= bs_v49

	local var_528_4, var_528_5 = pcall(function()
		return rage.exploit:get_defensive()
	end)

	if var_528_4 and var_528_5 then
		bs_v64 = true
	end
end)
events.level_change(function()
	bs_v20 = 0
	bs_v33 = 0
	bs_v49 = 0
	bs_v64 = false
	bs_v3 = false
	anim_cache = {}
	bar_cache = {}
	pulse_cache = {}
end)
events.round_start(function()
	bs_v20 = 0
	bs_v33 = 0
	bs_v49 = 0
	bs_v64 = false
	anim_cache = {}
	bar_cache = {}
	pulse_cache = {}
end)

bs_v79 = "✦"
bs_v96 = 52
bs_v110 = 52
bs_v127 = vector(bs_v96, bs_v110)
bs_v145 = bs_position_dragger:new("defensive_indicator", vector(bs_screen_size.x * 0.5, bs_screen_size.y - 55), "y")
bs_v164 = bs_smoothy.new(0)
bs_v172 = bs_smoothy.new(0)
bs_v195 = bs_smoothy.new(0)
bs_v215 = render.load_font("Verdana", vector(0, 30, 0), "ab")
bs_v235 = render.load_font("Verdana", vector(0, 34, 0), "ab")

events.render(function()
	bs_v1757 = bs_menu.info and bs_menu.info.def_ind

	if not bs_v1757 then
		return
	end

	bs_v1758 = ui.get_alpha() > 0
	bs_v1770 = false

	if bs_v1758 and bs_tab_dummy then
		bs_v1779, bs_v1781 = pcall(function()
			return bs_tab_dummy:get()
		end)
		bs_v1770 = bs_v1779 and bs_v1781 == 2
	end

	bs_v1778 = bs_v1758 and bs_v1770

	if not bs_v1757.switch:get() then
		bs_v164(0.06, false)

		return
	end

	bs_v145:update(bs_v127)

	if bs_v1778 then
		bs_draw_panel_bg(bs_v145.position, bs_v127, math.max(bs_v145.hover_anim, bs_v145.grab_anim))
	end

	bs_v1780 = entity.get_local_player()
	bs_v1782 = bs_v1780 ~= nil and bs_v1780:is_alive() and bs_v64 or bs_v1778

	bs_v164(bs_v1782 and 0.09 or 0.04, bs_v1782)

	bs_v1783 = bs_v164.value

	if bs_v1783 < 0.004 then
		return
	end

	bs_v1784 = globals.realtime
	bs_v1786 = (math.sin(bs_v1784 * 3) + 1) * 0.5
	bs_v1785 = bs_v1786 * bs_v1786

	bs_v172(0.08, bs_v1785)

	bs_v1760 = (math.sin(bs_v1784 * 1.8 - 1) + 1) * 0.5
	bs_v1759 = bs_v1760 * bs_v1760

	bs_v195(0.06, bs_v1759)

	bs_v1761 = bs_v172.value
	bs_v1762 = bs_v195.value
	bs_v1763 = bs_v1757.color:get()
	bs_v1764 = math.max(0, math.min(255, math.floor(bs_v1763.r * 0.55 + bs_v1763.r * 0.45 * bs_v1762)))
	bs_v1765 = math.max(0, math.min(255, math.floor(bs_v1763.g * 0.55 + bs_v1763.g * 0.45 * bs_v1762)))
	bs_v1766 = math.max(0, math.min(255, math.floor(bs_v1763.b * 0.55 + bs_v1763.b * 0.45 * bs_v1762)))
	bs_v1767 = math.floor(bs_v1783 * (22 + bs_v1762 * 18 + bs_v1761 * 10))
	bs_v1768 = math.floor(bs_v1783 * (185 + bs_v1762 * 40 + bs_v1761 * 20))
	bs_v1769 = bs_v145.position
	bs_v1771 = math.floor(bs_v1769.x)
	bs_v1772 = math.floor(bs_v1769.y + math.sin(bs_v1784 * 1.3) * 2 * bs_v1783)

	if bs_v1767 > 2 then
		bs_v1774 = {
			3,
			2,
			1
		}

		for iter_532_0, iter_532_1 in ipairs(bs_v1774) do
			bs_v1776 = math.floor(bs_v1767 * (1 - (iter_532_0 - 1) / #bs_v1774) * 0.5)

			if bs_v1776 > 1 then
				bs_v1777 = color(bs_v1764, bs_v1765, bs_v1766, bs_v1776)

				for iter_532_2, iter_532_3 in ipairs({
					{
						-iter_532_1,
						-iter_532_1
					},
					{
						iter_532_1,
						-iter_532_1
					},
					{
						-iter_532_1,
						iter_532_1
					},
					{
						iter_532_1,
						iter_532_1
					},
					{
						0,
						-iter_532_1
					},
					{
						0,
						iter_532_1
					},
					{
						-iter_532_1,
						0
					},
					{
						iter_532_1,
						0
					}
				}) do
					render.text(bs_v235, vector(bs_v1771 + iter_532_3[1], bs_v1772 + iter_532_3[2]), bs_v1777, "c", bs_v79)
				end
			end
		end
	end

	bs_v1773 = math.floor(bs_v1783 * (70 + bs_v1762 * 50))

	if bs_v1773 > 2 then
		bs_v1775 = color(bs_v1764, bs_v1765, bs_v1766, bs_v1773)

		for iter_532_4, iter_532_5 in ipairs({
			{
				-1,
				-1
			},
			{
				1,
				-1
			},
			{
				-1,
				1
			},
			{
				1,
				1
			}
		}) do
			render.text(bs_v215, vector(bs_v1771 + iter_532_5[1], bs_v1772 + iter_532_5[2]), bs_v1775, "c", bs_v79)
		end
	end

	render.text(bs_v215, vector(bs_v1771, bs_v1772), color(bs_v1764, bs_v1765, bs_v1766, bs_v1768), "c", bs_v79)
end)

bs_v2 = nil
bs_v16 = 120
bs_v30 = 3
bs_v47 = 2
bs_v63 = 3
bs_v78 = 6
bs_v95 = bs_position_dragger:new("velocity_indicator", vector(bs_screen_size.x * 0.5, bs_screen_size.y - 55), "y")
bs_v109 = bs_smoothy.new(0)
bs_v126 = bs_smoothy.new(0)
bs_v144 = -9
bs_v163 = 0
bs_v171 = render.load_font("Verdana", 13, "ab")

function bs_v194(arg_534_0, arg_534_1, arg_534_2)
	arg_534_2 = math.max(0, math.min(1, arg_534_2))

	return color(math.floor(arg_534_0.r + (arg_534_1.r - arg_534_0.r) * arg_534_2), math.floor(arg_534_0.g + (arg_534_1.g - arg_534_0.g) * arg_534_2), math.floor(arg_534_0.b + (arg_534_1.b - arg_534_0.b) * arg_534_2), math.floor(arg_534_0.a + (arg_534_1.a - arg_534_0.a) * arg_534_2))
end

events.render(function()
	bs_v1787 = bs_menu.info.velocity

	if not bs_v1787 then
		return
	end

	bs_v1788 = render.measure_text(bs_v171, nil, "A").y
	bs_v1802 = bs_v1787.switch:get() and bs_v1787.show_label:get()
	bs_v1816 = bs_v1787.switch:get() and bs_v1787.show_percent:get()
	bs_v1821 = 0

	if bs_v1802 then
		bs_v1821 = bs_v1821 + bs_v1788 + (bs_v1816 and bs_v63 or 0)
	end

	if bs_v1816 then
		bs_v1821 = bs_v1821 + bs_v1788
	end

	bs_v1822 = bs_v1821 + (bs_v1821 > 0 and bs_v78 or 0) + bs_v30

	if not bs_v1787.switch:get() then
		bs_v126(0.08, false)
		bs_v95:update(vector(bs_v16, bs_v1822))

		return
	end

	bs_v1823 = entity.get_local_player()

	if bs_v1823 == nil then
		return
	end

	bs_v1824 = bs_v1823.m_flVelocityModifier or 1
	bs_v1825 = bs_v1823:is_alive()
	bs_v1826 = ui.get_alpha() > 0
	bs_v1789 = false

	if bs_v1826 and bs_tab_dummy then
		bs_v1791, bs_v1794 = pcall(function()
			return bs_tab_dummy:get()
		end)
		bs_v1789 = bs_v1791 and bs_v1794 == 2
	end

	bs_v1790 = bs_v1824

	if bs_v1826 and bs_v1789 then
		bs_v1793 = globals.realtime * 0.18 % 1
		bs_v1790 = bs_v1793 < 0.5 and bs_v1793 * 2 or 2 - bs_v1793 * 2
		bs_v1790 = bs_v1790 * bs_v1790 * (3 - 2 * bs_v1790)
	end

	bs_v1792 = bs_v1825 and bs_v1790 < 0.99 or bs_v1826 and bs_v1789

	bs_v126(0.07, bs_v1792)
	bs_v95:update(vector(bs_v16, bs_v1822))

	if bs_v1826 and bs_v1789 then
		bs_draw_panel_bg(bs_v95.position, vector(bs_v16, bs_v1822), math.max(bs_v95.hover_anim, bs_v95.grab_anim))
	end

	if bs_v126.value <= 0.01 then
		return
	end

	bs_v109(0.055, bs_v1790)

	bs_v1795 = math.max(0, math.min(1, bs_v109.value))

	if bs_v163 < 0.97 and bs_v1795 >= 0.97 then
		bs_v144 = globals.realtime
	end

	bs_v163 = bs_v1795
	bs_v1796 = math.max(0, math.min(1, (globals.realtime - bs_v144) / 0.55))
	bs_v1797 = bs_v1796 < 1 and math.sin(bs_v1796 * math.pi) or 0
	bs_v1798 = bs_v1787.col_bar:get()
	bs_v1799 = bs_v1787.col_low and bs_v1787.col_low:get() or bs_v1787.col_bar2 and bs_v1787.col_bar2:get() or color(255, 255, 255, 255)
	bs_v1800 = bs_v194(bs_v1799, bs_v1798, bs_v1795)
	bs_v1801 = bs_v126.value
	bs_v1803 = math.floor(bs_v1801 * 255)
	bs_v1804 = bs_v95.position
	bs_v1805 = math.floor(bs_v1804.x)
	bs_v1806 = math.floor(bs_v1804.y - bs_v1822 * 0.5)

	if bs_v1802 then
		bs_v1809 = render.measure_text(bs_v171, nil, "velocity")

		render.text(bs_v171, vector(bs_v1805 - math.floor(bs_v1809.x * 0.5), bs_v1806), color(105, 105, 110, math.floor(bs_v1803 * 0.78)), nil, "velocity")

		bs_v1806 = bs_v1806 + bs_v1788 + bs_v63
	end

	if bs_v1816 then
		bs_v1808 = ("%d%%"):format(math.floor(bs_v1790 * 100))
		bs_v1811 = render.measure_text(bs_v171, nil, bs_v1808)
		bs_v1813 = bs_v194(color(105, 105, 110, 255), bs_v1800, bs_v1795)

		render.text(bs_v171, vector(bs_v1805 - math.floor(bs_v1811.x * 0.5) + 1, bs_v1806 + 1), color(0, 0, 0, math.floor(bs_v1803 * 0.18)), nil, bs_v1808)
		render.text(bs_v171, vector(bs_v1805 - math.floor(bs_v1811.x * 0.5), bs_v1806), color(bs_v1813.r, bs_v1813.g, bs_v1813.b, math.floor(bs_v1803 * 0.88)), nil, bs_v1808)

		bs_v1806 = bs_v1806 + bs_v1788
	end

	bs_v1807 = bs_v1805 - math.floor(bs_v16 * 0.5)
	bs_v1810 = bs_v1807 + bs_v16
	bs_v1812 = bs_v1806 + (bs_v1821 > 0 and bs_v78 or 0)
	bs_v1814 = bs_v1812 + bs_v30

	render.rect(vector(bs_v1807, bs_v1812), vector(bs_v1810, bs_v1814), color(255, 255, 255, math.floor(bs_v1803 * 0.09)), bs_v47)

	bs_v1815 = math.floor(bs_v16 * bs_v1795)

	if bs_v1815 > 1 then
		bs_v1817 = bs_v1807 + bs_v1815
		bs_v1818 = math.floor(bs_v1803 * 0.16 * bs_v1795)

		if bs_v1818 > 2 then
			render.rect(vector(bs_v1807, bs_v1812 - 1), vector(bs_v1817, bs_v1814 + 2), color(bs_v1800.r, bs_v1800.g, bs_v1800.b, bs_v1818), bs_v47)
		end

		render.rect(vector(bs_v1807, bs_v1812), vector(bs_v1817, bs_v1814), color(bs_v1800.r, bs_v1800.g, bs_v1800.b, math.floor(bs_v1803 * 0.88)), bs_v47)
		render.rect(vector(bs_v1807, bs_v1812), vector(bs_v1817, bs_v1812 + math.ceil(bs_v30 * 0.5)), color(255, 255, 255, math.floor(bs_v1803 * 0.16)), bs_v47)

		if bs_v1797 > 0.01 then
			render.rect(vector(bs_v1807, bs_v1812), vector(bs_v1817, bs_v1814), color(255, 255, 255, math.floor(bs_v1803 * 0.45 * bs_v1797)), bs_v47)
		end

		if bs_v1795 >= 0.97 then
			bs_v1820 = (math.sin(globals.realtime * 3.2) + 1) * 0.5
			bs_v1819 = bs_v1820 * bs_v1820

			if bs_v1819 > 0.01 then
				render.rect(vector(bs_v1807 - 2, bs_v1812 - 2), vector(bs_v1817 + 2, bs_v1814 + 2), color(bs_v1800.r, bs_v1800.g, bs_v1800.b, math.floor(bs_v1803 * 0.2 * bs_v1819)), bs_v47 + 1)
			end
		end
	end
end)

bs_v15 = {
	breaking = false,
	last_lc = 0,
	discharge = 0
}
bs_v29 = nil
bs_v43 = 14
bs_v62 = 7
bs_v77 = 5
bs_v94 = 2
bs_v108 = 2
bs_v125 = 8
bs_v143 = 5
bs_v162 = bs_v43 * (bs_v62 + bs_v94) - bs_v94 + bs_v125 * 2
bs_v170 = bs_position_dragger:new("lc_indicator", vector(bs_screen_size.x * 0.5, bs_screen_size.y - 55), "y")
bs_v193 = bs_smoothy.new(0)
bs_v214 = render.load_font("Verdana", 12, "ab")
bs_v234 = render.load_font("Verdana", 13, "ab")
bs_v254 = nil
bs_v281 = 0
bs_v296 = 0
bs_v309 = 0
bs_v321 = false
bs_v334 = false
bs_v347 = 0
bs_v361 = {}
bs_v369 = {}
bs_v379 = 0

for iter_0_39 = 1, bs_v43 do
	bs_v361[iter_0_39] = 0
end

function bs_v388(arg_537_0, arg_537_1, arg_537_2)
	arg_537_2 = math.max(0, math.min(1, arg_537_2))

	return color(math.floor(arg_537_0.r + (arg_537_1.r - arg_537_0.r) * arg_537_2), math.floor(arg_537_0.g + (arg_537_1.g - arg_537_0.g) * arg_537_2), math.floor(arg_537_0.b + (arg_537_1.b - arg_537_0.b) * arg_537_2), math.floor(arg_537_0.a + (arg_537_1.a - arg_537_0.a) * arg_537_2))
end

function bs_v396(arg_538_0, arg_538_1)
	if arg_538_1 == 14 then
		return "$$$", arg_538_0.col_wt:get()
	elseif arg_538_1 == 13 then
		return "amazing", arg_538_0.col_god:get()
	elseif arg_538_1 == 12 then
		return "ideal lc", arg_538_0.col_ideal:get()
	elseif arg_538_1 >= 10 then
		return "nice", arg_538_0.col_ideal:get()
	elseif arg_538_1 >= 7 then
		return "good", arg_538_0.col_good:get()
	elseif arg_538_1 >= 4 then
		return "ok", arg_538_0.col_ok:get()
	elseif arg_538_1 >= 1 then
		return "bad", arg_538_0.col_bad:get()
	else
		return "failed", arg_538_0.col_failed:get()
	end
end

events.createmove(function()
	local var_539_0 = bs_menu.info.lc_ind
	local var_539_1 = entity.get_local_player()

	if not var_539_1 or not var_539_1:is_alive() then
		bs_v347 = 0

		return
	end

	local var_539_2 = var_539_1.m_nTickBase or 0

	if math.abs(var_539_2 - bs_v347) > 64 then
		bs_v347 = 0
	end

	if var_539_2 > bs_v347 then
		bs_v347 = var_539_2
	end

	local var_539_3 = math.min(14, math.max(0, bs_v347 - var_539_2 - 1))
	local var_539_4 = rage.exploit:get()
	local var_539_5 = var_539_1.m_vecVelocity.z > 0

	if var_539_4 < bs_v296 and var_539_5 and not bs_v321 then
		bs_v321 = true
		bs_v281 = bs_v309
		bs_v254 = globals.realtime + (bs_v309 == 14 and 2 or 0.66)
	end

	if bs_v321 and var_539_4 == 0 then
		bs_v321 = false
	end

	if bs_v254 and globals.realtime > bs_v254 then
		bs_v254 = nil
	end

	bs_v296 = var_539_4
	bs_v309 = var_539_3

	local var_539_6 = bs_config.rage.main.double_tap:get()
	local var_539_7 = bs_config.rage.main.hide_shots:get()

	bs_v334 = var_539_6 or var_539_7 or bs_v254 ~= nil or var_539_3 > 0
	bs_v15.last_lc = bs_v309
	bs_v15.breaking = bs_v334
	bs_v15.timer = bs_v254
	bs_v15.discharge = bs_v281
end)
events.render(function()
	bs_v1827 = bs_menu.info.lc_ind

	if not bs_v1827 then
		return
	end

	bs_v1828 = math.max(0.001, math.min(globals.frametime, 0.05))
	bs_v1840 = render.measure_text(bs_v234, nil, "A").y
	bs_v1859 = render.measure_text(bs_v214, nil, "A").y
	bs_v1876 = 0

	if bs_v1827.switch:get() and bs_v1827.show_label:get() then
		bs_v1876 = bs_v1876 + bs_v1840 + bs_v143
	end

	if bs_v1827.switch:get() and bs_v1827.show_ticks:get() then
		bs_v1876 = bs_v1876 + bs_v1859 + bs_v143
	end

	bs_v1884 = bs_v1876 + (bs_v1827.switch:get() and bs_v1827.show_bar:get() and bs_v77 or 0) + bs_v125

	if not bs_v1827.switch:get() then
		bs_v193(0.08, false)
		bs_v170:update(vector(bs_v162, math.max(bs_v1884, 20)))

		return
	end

	bs_v1885 = entity.get_local_player()

	bs_v1886 = ui.get_alpha() > 0
	bs_v1887 = false

	if bs_v1886 and bs_tab_dummy then
		bs_v1830, bs_v1832 = pcall(function()
			return bs_tab_dummy:get()
		end)
		bs_v1887 = bs_v1830 and bs_v1832 == 2
	end

	bs_v1829 = bs_v1885 and bs_v1885:is_alive() or false
	-- LC indicator: visible only when alive and actively LCing (and dead = hidden)
	local bs_lc_active = bs_v334 or bs_v15.breaking or bs_v254 ~= nil or (bs_v309 or 0) > 0
	local bs_menu_preview = bs_v1886 and bs_v1887 and bs_v1829
	bs_v1831 = bs_v1827.switch:get() and ((bs_v1829 and bs_lc_active) or bs_menu_preview)

	bs_v193(0.08, bs_v1831)
	bs_v170:update(vector(bs_v162, math.max(bs_v1884, 20)))

	if bs_v1886 and bs_v1887 then
		bs_draw_panel_bg(bs_v170.position, vector(bs_v162, math.max(bs_v1884, 20)), math.max(bs_v170.hover_anim, bs_v170.grab_anim))
	end

	if bs_v193.value <= 0.01 then
		return
	end

	bs_v1833 = bs_v193.value
	bs_v1834 = math.floor(bs_v1833 * 255)
	bs_v1835 = bs_v170.position
	bs_v1836 = math.floor(bs_v1835.x)
	bs_v1837 = math.floor(bs_v1835.y - math.max(bs_v1884, 20) * 0.5)
	bs_v1838 = bs_v309

	if bs_v1886 and bs_v1887 and not bs_v1829 then
		bs_v1838 = math.floor((math.sin(globals.realtime * 0.9) + 1) * 0.5 * 14)
	end

	bs_v1839 = nil
	bs_v1841 = nil

	if bs_v254 then
		bs_v1839, bs_v1841 = bs_v396(bs_v1827, bs_v281)
	elseif bs_v1886 and bs_v1887 and not bs_v1829 then
		bs_v1839 = "lc status"
		bs_v1841 = bs_v1827.col_ok:get()
	else
		bs_v1839, bs_v1841 = bs_v396(bs_v1827, bs_v1838)
	end

	bs_v379 = bs_v379 + bs_v1828 * 1.8

	if bs_v1827.show_label:get() then
		bs_v1843 = bs_v1839 or "lc status"
		bs_v1846 = bs_v1841 or bs_v1827.col_ok:get()
		bs_v1849 = render.measure_text(bs_v234, nil, bs_v1843)
		bs_v1851 = bs_v1836 - math.floor(bs_v1849.x * 0.5)
		bs_v1853 = bs_v379 % 1.3 - 0.15
		bs_v1855 = {}

		for iter_540_0 = 1, #bs_v1843 do
			bs_v1855[iter_540_0] = bs_v1843:sub(iter_540_0, iter_540_0)
		end

		bs_v1857 = bs_v1849.x
		bs_v1858 = bs_v1851

		for iter_540_1, iter_540_2 in ipairs(bs_v1855) do
			bs_v1864 = render.measure_text(bs_v234, nil, iter_540_2)
			bs_v1866 = (bs_v1858 - bs_v1851 + bs_v1864.x * 0.5) / math.max(bs_v1857, 1)
			bs_v1868 = math.abs(bs_v1866 - bs_v1853)
			bs_v1871 = math.max(0, 1 - bs_v1868 / 0.15)
			bs_v1870 = bs_v1871 * bs_v1871 * bs_v1871
			bs_v1873 = math.floor(bs_v1833 * (bs_v1846.a / 255) * (0.88 + bs_v1870 * 0.12) * 255)
			bs_v1875 = math.min(255, math.floor(bs_v1846.r + (255 - bs_v1846.r) * bs_v1870 * 0.55))
			bs_v1878 = math.min(255, math.floor(bs_v1846.g + (255 - bs_v1846.g) * bs_v1870 * 0.55))
			bs_v1880 = math.min(255, math.floor(bs_v1846.b + (255 - bs_v1846.b) * bs_v1870 * 0.55))
			bs_v1882 = math.floor(bs_v1873 * 0.18)

			if bs_v1882 > 3 then
				render.text(bs_v234, vector(bs_v1858 + 1, bs_v1837 + 1), color(0, 0, 0, bs_v1882), nil, iter_540_2)
			end

			render.text(bs_v234, vector(bs_v1858, bs_v1837), color(bs_v1875, bs_v1878, bs_v1880, bs_v1873), nil, iter_540_2)

			bs_v1858 = bs_v1858 + bs_v1864.x
		end

		bs_v1837 = bs_v1837 + bs_v1840 + bs_v143
	end

	if bs_v1827.show_ticks:get() then
		bs_v1845 = (bs_v254 and bs_v281 or bs_v1838) .. "t"
		bs_v1848 = render.measure_text(bs_v214, nil, bs_v1845)

		render.text(bs_v214, vector(bs_v1836 - math.floor(bs_v1848.x * 0.5), bs_v1837), color(185, 185, 190, math.floor(bs_v1834 * 0.55)), nil, bs_v1845)

		bs_v1837 = bs_v1837 + bs_v1859 + bs_v143
	end

	bs_v1842 = bs_v254 and bs_v281 or bs_v1838
	bs_v1844 = globals.realtime
	bs_v1847 = math.min(0.22 * bs_v1828 / 0.01667, 0.9)

	if bs_v1827.show_bar:get() then
		bs_v1850 = bs_v43 * (bs_v62 + bs_v94) - bs_v94
		bs_v1852 = bs_v1836 - math.floor(bs_v1850 * 0.5)
		bs_v1854 = bs_v1841 or bs_v1827.col_ok:get()

		for iter_540_3 = 1, bs_v43 do
			bs_v1861 = bs_v1842 >= bs_v43 - iter_540_3 + 1 and 1 or 0
			bs_v361[iter_540_3] = bs_v361[iter_540_3] + (bs_v1861 - bs_v361[iter_540_3]) * bs_v1847
			bs_v1862 = bs_v361[iter_540_3]

			if bs_v1862 < 0.01 then
				bs_v1862 = 0
			end

			bs_v1863 = bs_v1852 + (iter_540_3 - 1) * (bs_v62 + bs_v94)
			bs_v1865 = bs_v1863 + bs_v62
			bs_v1867 = bs_v1837
			bs_v1869 = bs_v1867 + bs_v77
			bs_v1872 = (iter_540_3 - 1) / math.max(bs_v43 - 1, 1)
			bs_v1874 = 0

			if bs_v1842 >= 12 then
				bs_v1874 = (math.sin(bs_v1844 * 4.5 + bs_v1872 * math.pi * 2) + 1) * 0.5
				bs_v1874 = bs_v1874 * bs_v1874 * 0.45
			end

			bs_v1877 = math.floor(bs_v1834 * 0.12)

			render.rect(vector(bs_v1863, bs_v1867), vector(bs_v1865, bs_v1869), color(18, 18, 22, bs_v1877), bs_v108)

			if bs_v1862 > 0.005 then
				bs_v1879 = math.floor(bs_v1833 * bs_v1862 * (0.8 + bs_v1874 * 0.2) * 255)
				bs_v1881 = math.floor(bs_v1879 * 0.2 * bs_v1862)

				if bs_v1881 > 2 then
					render.rect(vector(bs_v1863 - 1, bs_v1867 - 1), vector(bs_v1865 + 1, bs_v1869 + 1), color(bs_v1854.r, bs_v1854.g, bs_v1854.b, bs_v1881), bs_v108 + 1)
				end

				render.rect(vector(bs_v1863, bs_v1867), vector(bs_v1865, bs_v1869), color(bs_v1854.r, bs_v1854.g, bs_v1854.b, bs_v1879), bs_v108)

				bs_v1883 = math.floor(bs_v1879 * 0.2)

				if bs_v1883 > 2 then
					render.rect(vector(bs_v1863, bs_v1867), vector(bs_v1865, bs_v1867 + math.ceil(bs_v77 * 0.45)), color(255, 255, 255, bs_v1883), bs_v108)
				end
			end
		end

		bs_v1856 = math.floor(bs_v1834 * 0.08)

		if bs_v1856 > 1 then
			for iter_540_4 = 1, bs_v43 do
				bs_v1860 = bs_v1852 + (iter_540_4 - 1) * (bs_v62 + bs_v94)

				render.rect_outline(vector(bs_v1860, bs_v1837), vector(bs_v1860 + bs_v62, bs_v1837 + bs_v77), color(255, 255, 255, bs_v1856), 1, bs_v108)
			end
		end
	else
		for iter_540_5 = 1, bs_v43 do
			bs_v361[iter_540_5] = 0
		end
	end
end)

bs_v42 = nil
bs_v57 = 120
bs_v76 = 3
bs_v93 = 2
bs_v107 = 3
bs_v124 = 6
bs_v142 = "✓"
bs_v161 = bs_position_dragger:new("bruteforce_indicator", vector(bs_screen_size.x * 0.5, bs_screen_size.y - 55), "y")
bs_v169 = bs_smoothy.new(0)
bs_v192 = render.load_font("Verdana", 13, "ab")
bs_v231 = bs_smoothy.new(0)
bs_v251 = bs_smoothy.new(0)
bs_v269 = bs_smoothy.new(0)
bs_v280 = bs_smoothy.new(0.5)
bs_v295 = bs_smoothy.new(0.5)
bs_v308 = {
	rem_n = 0,
	fill_d = 0,
	fill_n = 0,
	active = false,
	prev_fr = 0,
	shim_tr = -9,
	prev_fl = 0,
	shim_tl = -9,
	def_valid = false,
	abf_valid = false,
	def_expire = 0,
	abf_expire = 0,
	reset_d = 3,
	reset_n = 3,
	rem_d = 0,
	alpha = bs_smoothy.new(0),
	anim_l = bs_smoothy.new(0),
	anim_r = bs_smoothy.new(0)
}
bs_v320 = {
	prev_f = 0,
	shim_t = -9,
	col_is_def = false,
	rem = 0,
	active = false,
	expire = 0,
	fill = 0,
	reset = 3,
	alpha = bs_smoothy.new(0),
	anim = bs_smoothy.new(0)
}

function bs_v333(arg_542_0, arg_542_1, arg_542_2)
	arg_542_2 = math.max(0, math.min(1, arg_542_2))

	return color(math.floor(arg_542_0.r + (arg_542_1.r - arg_542_0.r) * arg_542_2), math.floor(arg_542_0.g + (arg_542_1.g - arg_542_0.g) * arg_542_2), math.floor(arg_542_0.b + (arg_542_1.b - arg_542_0.b) * arg_542_2), math.floor(arg_542_0.a + (arg_542_1.a - arg_542_0.a) * arg_542_2))
end

function bs_v346(arg_543_0, arg_543_1, arg_543_2, arg_543_3, arg_543_4, arg_543_5, arg_543_6, arg_543_7)
	local var_543_0 = math.floor((arg_543_1 - arg_543_0) * 0.5)
	local var_543_1 = arg_543_0 + var_543_0
	local var_543_2 = math.floor(var_543_0 * arg_543_4)

	if var_543_2 < 1 then
		return
	end

	local var_543_3
	local var_543_4

	if arg_543_7 then
		var_543_3 = var_543_1 - var_543_2
		var_543_4 = var_543_1
	else
		var_543_3 = var_543_1
		var_543_4 = var_543_1 + var_543_2
	end

	local var_543_5 = math.floor(arg_543_6 * 0.16 * arg_543_4)

	if var_543_5 > 2 then
		render.rect(vector(var_543_3, arg_543_2 - 1), vector(var_543_4, arg_543_3 + 2), color(arg_543_5.r, arg_543_5.g, arg_543_5.b, var_543_5), bs_v93)
	end

	render.rect(vector(var_543_3, arg_543_2), vector(var_543_4, arg_543_3), color(arg_543_5.r, arg_543_5.g, arg_543_5.b, math.floor(arg_543_6 * 0.88)), bs_v93)
	render.rect(vector(var_543_3, arg_543_2), vector(var_543_4, arg_543_2 + math.ceil(bs_v76 * 0.5)), color(255, 255, 255, math.floor(arg_543_6 * 0.16)), bs_v93)
end

function bs_v360(arg_544_0, arg_544_1, arg_544_2, arg_544_3)
	local var_544_0 = math.min(arg_544_2 * arg_544_3 / 0.01667, 0.95)

	arg_544_0(var_544_0, arg_544_1)
end

events.render(function()
	bs_v1888 = bs_menu.info.abf_ind

	if not bs_v1888 then
		return
	end

	bs_v1889 = math.max(0.001, math.min(globals.frametime, 0.05))
	bs_v1902 = render.measure_text(bs_v192, nil, "A").y
	bs_v1914 = bs_v1888.switch:get() and bs_v1888.show_label:get()
	bs_v1934 = bs_v1888.switch:get() and bs_v1888.show_timer:get()
	bs_v1952 = 0

	if bs_v1914 then
		bs_v1952 = bs_v1952 + bs_v1902 + (bs_v1934 and bs_v107 or 0)
	end

	if bs_v1934 then
		bs_v1952 = bs_v1952 + bs_v1902
	end

	bs_v1988 = bs_v1952 + (bs_v1952 > 0 and bs_v124 or 0) + bs_v76

	if not bs_v1888.switch:get() then
		bs_v169(0.08, false)
		bs_v161:update(vector(bs_v57, bs_v1988))

		return
	end

	bs_v2005 = entity.get_local_player()
	bs_v2006 = bs_v2005 ~= nil and bs_v2005:is_alive()
	bs_v2007 = ui.get_alpha() > 0
	bs_v1890 = false

	if bs_v2007 and bs_tab_dummy then
		bs_v1892, bs_v1894 = pcall(function()
			return bs_tab_dummy:get()
		end)
		bs_v1890 = bs_v1892 and bs_v1894 == 2
	end

	bs_v1891 = bs_v2007 and bs_v1890
	bs_v1893 = globals.realtime
	bs_v1895 = bs_get_state.get(bs_legit_aa.is_working)
	bs_v1896 = bs_menu.antiaim.defensive
	bs_v1897 = bs_anti_brute.ind_latch

	if bs_v1897.is_working and bs_v1893 >= bs_v1897.reset_time then
		bs_v1897.is_working = false
		bs_v1897.triggered_state = nil
	end

	bs_v1898 = bs_defensive_mgr.def_ind_latch

	if bs_v1898.is_working and bs_v1893 >= bs_v1898.reset_time then
		bs_v1898.is_working = false
		bs_v1898.triggered_state = nil
	end

	bs_v1899 = bs_v1897.is_working
	bs_v1900 = bs_v1897.triggered_state
	bs_v1901 = bs_menu.antiaim.angles.builder and bs_v1900 and bs_menu.antiaim.angles.builder[bs_v1900]
	bs_v1903 = bs_v1901 and bs_v1901.anti_bruteforce and bs_v1901.anti_bruteforce:get() or false
	bs_v1904 = bs_v1899 and bs_v1903
	bs_v1905 = bs_v1897.reset_dur and bs_v1897.reset_dur > 0 and bs_v1897.reset_dur or bs_v1901 and bs_v1901.abf_reset_timer and bs_v1901.abf_reset_timer:get() or 3
	bs_v1907 = bs_v1904 and math.max(0, bs_v1897.reset_time - bs_v1893) or 0
	bs_v1908 = bs_v1904 and bs_v1905 > 0 and math.min(1, bs_v1907 / bs_v1905) or 0
	bs_v1909 = bs_v1898.is_working
	bs_v1910 = bs_v1898.triggered_state
	bs_v1911 = bs_v1896 and bs_v1896.settings and bs_v1910 and bs_v1896.settings[bs_v1910]
	bs_v1912 = bs_v1911 and bs_v1911.def_abf and bs_v1911.def_abf:get() or false
	bs_v1913 = bs_v1909 and bs_v1912
	bs_v1915 = bs_v1898.reset_dur and bs_v1898.reset_dur > 0 and bs_v1898.reset_dur or bs_v1911 and bs_v1911.def_abf_reset and bs_v1911.def_abf_reset:get() or 3
	bs_v1917 = bs_v1913 and math.max(0, bs_v1898.reset_time - bs_v1893) or 0
	bs_v1918 = bs_v1913 and bs_v1915 > 0 and math.min(1, bs_v1917 / bs_v1915) or 0
	bs_v1919 = bs_v1899 and bs_v1909

	if bs_v1891 then
		bs_v1921 = 0.3 + 0.55 * ((math.sin(bs_v1893 * 1.4) + 1) * 0.5)
		bs_v1924 = 0.3 + 0.55 * ((math.sin(bs_v1893 * 1.4 + 1.3) + 1) * 0.5)

		bs_v360(bs_v280, bs_v1921, 0.12, bs_v1889)
		bs_v360(bs_v295, bs_v1924, 0.12, bs_v1889)

		bs_v1908 = bs_v280.value
		bs_v1918 = bs_v295.value
		bs_v1906 = bs_v1908 * bs_v1905
		bs_v1916 = bs_v1918 * bs_v1915
		bs_v1904 = true
		bs_v1913 = true
		bs_v1919 = true

		bs_v360(bs_v308.anim_l, bs_v1908, 0.12, bs_v1889)
		bs_v360(bs_v308.anim_r, bs_v1918, 0.12, bs_v1889)

		bs_v308.abf_valid = true
		bs_v308.def_valid = true
	end

	bs_v1920 = bs_v2006 and (bs_v1904 or bs_v1913) or bs_v1891

	bs_v169(0.07, bs_v1920)

	if bs_v1919 and not bs_v1891 and not (bs_v320.active and bs_v320.alpha.value > 0.01) and not bs_v308.active then
		bs_v308.active = true
		bs_v308.abf_expire = bs_v1897.reset_time
		bs_v308.def_expire = bs_v1898.reset_time
		bs_v308.reset_n = bs_v1905
		bs_v308.reset_d = bs_v1915
		bs_v308.shim_tl = -9
		bs_v308.prev_fl = 0
		bs_v308.shim_tr = -9
		bs_v308.prev_fr = 0

		bs_v308.anim_l(1, bs_v1908)
		bs_v308.anim_r(1, bs_v1918)
	end

	if bs_v308.active then
		bs_v1923 = bs_v1893 < bs_v308.abf_expire
		bs_v1926 = bs_v1893 < bs_v308.def_expire
		bs_v308.abf_valid = bs_v1923
		bs_v308.def_valid = bs_v1926

		if bs_v1923 then
			bs_v308.rem_n = math.max(0, bs_v308.abf_expire - bs_v1893)
			bs_v308.fill_n = bs_v308.reset_n > 0 and math.min(1, bs_v308.rem_n / bs_v308.reset_n) or 0
		else
			bs_v308.rem_n = 0
			bs_v308.fill_n = 0
		end

		if bs_v1926 then
			bs_v308.rem_d = math.max(0, bs_v308.def_expire - bs_v1893)
			bs_v308.fill_d = bs_v308.reset_d > 0 and math.min(1, bs_v308.rem_d / bs_v308.reset_d) or 0
		else
			bs_v308.rem_d = 0
			bs_v308.fill_d = 0
		end

		bs_v1928 = bs_v1923 or bs_v1926

		bs_v308.alpha(0.07, bs_v1928)

		if bs_v308.alpha.value <= 0.01 then
			bs_v308.active = false
			bs_v308.abf_valid = false
			bs_v308.def_valid = false
		end
	end

	bs_v1922 = bs_v1904 and not bs_v1913 or bs_v1913 and not bs_v1904
	bs_v1925 = bs_v308.active and bs_v308.alpha.value > 0.01

	if bs_v320.active then
		bs_v1927 = bs_v320.alpha.value > 0.01
	end

	if bs_v1922 and not bs_v1919 and not bs_v320.active and not bs_v1925 and not bs_v1891 then
		bs_v320.active = true
		bs_v320.col_is_def = bs_v1913 and not bs_v1904

		if bs_v320.col_is_def then
			bs_v320.expire = bs_v1898.reset_time
			bs_v320.reset = bs_v1915
			bs_v1932 = bs_v1918

			bs_v320.anim(1, bs_v1932)
		else
			bs_v320.expire = bs_v1897.reset_time
			bs_v320.reset = bs_v1905
			bs_v1931 = bs_v1908

			bs_v320.anim(1, bs_v1931)
		end

		bs_v320.shim_t = -9
		bs_v320.prev_f = 0
	end

	if bs_v320.active then
		bs_v1930 = bs_v1893 < bs_v320.expire

		if bs_v1930 then
			bs_v320.rem = math.max(0, bs_v320.expire - bs_v1893)
			bs_v320.fill = bs_v320.reset > 0 and math.min(1, bs_v320.rem / bs_v320.reset) or 0
		else
			bs_v320.rem = 0
			bs_v320.fill = 0
		end

		bs_v320.alpha(0.07, bs_v1930)

		if bs_v320.alpha.value <= 0.01 then
			bs_v320.active = false
		end
	end

	bs_v161:update(vector(bs_v57, bs_v1988))

	if bs_v1891 then
		bs_draw_panel_bg(bs_v161.position, vector(bs_v57, bs_v1988), math.max(bs_v161.hover_anim, bs_v161.grab_anim))
	end

	bs_v1929 = bs_v1888.col_bar:get()
	bs_v1933 = bs_v1888.col_bar_def and bs_v1888.col_bar_def:get() or color(255, 140, 80, 255)
	bs_v1935 = bs_v1888.col_idle:get()
	bs_v1936 = bs_v161.position
	bs_v1937 = math.floor(bs_v1936.x)

	if bs_v308.active and bs_v308.alpha.value > 0.01 or bs_v1891 then
		bs_v1939 = bs_v1891 and 255 or math.floor(bs_v308.alpha.value * 255)
		bs_v1941 = math.floor(bs_v1936.y - bs_v1988 * 0.5)
		bs_v1943 = bs_v1891 and bs_v280.value or bs_v308.fill_n
		bs_v1945 = bs_v1891 and bs_v295.value or bs_v308.fill_d
		bs_v1947 = bs_v1891 and bs_v1943 * bs_v1905 or bs_v308.rem_n
		bs_v1949 = bs_v1891 and bs_v1945 * bs_v1915 or bs_v308.rem_d

		bs_v1951 = not bs_v308.abf_valid

		bs_v1954 = not bs_v308.def_valid

		bs_v360(bs_v308.anim_l, bs_v1943, 0.1, bs_v1889)
		bs_v360(bs_v308.anim_r, bs_v1945, 0.1, bs_v1889)

		bs_v1956 = math.max(0, math.min(1, bs_v308.anim_l.value))
		bs_v1960 = math.max(0, math.min(1, bs_v308.anim_r.value))

		if bs_v308.prev_fl < 0.97 and bs_v1956 >= 0.97 then
			bs_v308.shim_tl = bs_v1893
		end

		bs_v308.prev_fl = bs_v1956

		if bs_v308.prev_fr < 0.97 and bs_v1960 >= 0.97 then
			bs_v308.shim_tr = bs_v1893
		end

		bs_v308.prev_fr = bs_v1960
		bs_v1963 = math.max(0, math.min(1, (bs_v1893 - bs_v308.shim_tl) / 0.55))
		bs_v1966 = bs_v1963 < 1 and math.sin(bs_v1963 * math.pi) or 0
		bs_v1968 = math.max(0, math.min(1, (bs_v1893 - bs_v308.shim_tr) / 0.55))
		bs_v1970 = bs_v1968 < 1 and math.sin(bs_v1968 * math.pi) or 0

		if bs_v1914 then
			bs_v1974 = render.measure_text(bs_v192, nil, "bruteforce")

			render.text(bs_v192, vector(bs_v1937 - math.floor(bs_v1974.x * 0.5), bs_v1941), color(105, 105, 110, math.floor(bs_v1939 * 0.78)), nil, "bruteforce")

			bs_v1941 = bs_v1941 + bs_v1902 + bs_v107
		end

		if bs_v1934 then
			bs_v1973 = math.floor(bs_v57 * 0.5)

			if bs_v1951 then
				bs_v1980 = bs_v333(color(105, 105, 110, 255), bs_v1929, bs_v1956)
				bs_v1987 = render.measure_text(bs_v192, nil, bs_v142)

				render.text(bs_v192, vector(bs_v1937 - bs_v1973 + math.floor((bs_v1973 - bs_v1987.x) * 0.5), bs_v1941), color(bs_v1980.r, bs_v1980.g, bs_v1980.b, math.floor(bs_v1939 * 0.88)), nil, bs_v142)
			else
				bs_v1979 = ("%.1fs"):format(bs_v1947)
				bs_v1986 = render.measure_text(bs_v192, nil, bs_v1979)
				bs_v1991 = bs_v333(color(105, 105, 110, 255), bs_v1929, bs_v1956)

				render.text(bs_v192, vector(bs_v1937 - bs_v1973 + math.floor((bs_v1973 - bs_v1986.x) * 0.5), bs_v1941), color(bs_v1991.r, bs_v1991.g, bs_v1991.b, math.floor(bs_v1939 * 0.88)), nil, bs_v1979)
			end

			if bs_v1954 then
				bs_v1978 = bs_v333(color(105, 105, 110, 255), bs_v1933, bs_v1960)
				bs_v1985 = render.measure_text(bs_v192, nil, bs_v142)

				render.text(bs_v192, vector(bs_v1937 + math.floor((bs_v1973 - bs_v1985.x) * 0.5), bs_v1941), color(bs_v1978.r, bs_v1978.g, bs_v1978.b, math.floor(bs_v1939 * 0.88)), nil, bs_v142)
			else
				bs_v1977 = ("%.1fs"):format(bs_v1949)
				bs_v1984 = render.measure_text(bs_v192, nil, bs_v1977)
				bs_v1990 = bs_v333(color(105, 105, 110, 255), bs_v1933, bs_v1960)

				render.text(bs_v192, vector(bs_v1937 + math.floor((bs_v1973 - bs_v1984.x) * 0.5), bs_v1941), color(bs_v1990.r, bs_v1990.g, bs_v1990.b, math.floor(bs_v1939 * 0.88)), nil, bs_v1977)
			end

			bs_v1941 = bs_v1941 + bs_v1902
		end

		bs_v1972 = bs_v1937 - math.floor(bs_v57 * 0.5)
		bs_v1976 = bs_v1972 + bs_v57
		bs_v1983 = bs_v1941 + (bs_v1952 > 0 and bs_v124 or 0)
		bs_v1989 = bs_v1983 + bs_v76
		bs_v1992 = bs_v1972 + math.floor(bs_v57 * 0.5)

		render.rect(vector(bs_v1972, bs_v1983), vector(bs_v1976, bs_v1989), color(255, 255, 255, math.floor(bs_v1939 * 0.09)), bs_v93)

		if not bs_v1951 then
			bs_v346(bs_v1972, bs_v1976, bs_v1983, bs_v1989, bs_v1956, bs_v333(bs_v1935, bs_v1929, bs_v1956), bs_v1939, true)
		end

		if not bs_v1954 then
			bs_v346(bs_v1972, bs_v1976, bs_v1983, bs_v1989, bs_v1960, bs_v333(bs_v1935, bs_v1933, bs_v1960), bs_v1939, false)
		end

		bs_v1993 = math.floor(bs_v57 * 0.5)
		bs_v1994 = bs_v1972 + bs_v1993

		if not bs_v1951 then
			bs_v1996 = math.floor(bs_v1993 * bs_v1956)

			if bs_v1996 > 1 then
				bs_v1998 = bs_v1994 - bs_v1996

				if bs_v1966 > 0.01 then
					render.rect(vector(bs_v1998, bs_v1983), vector(bs_v1994, bs_v1989), color(255, 255, 255, math.floor(bs_v1939 * 0.45 * bs_v1966)), bs_v93)
				end

				if bs_v1956 >= 0.97 then
					bs_v2002 = (math.sin(bs_v1893 * 3.2) + 1) * 0.5
					bs_v2001 = bs_v2002 * bs_v2002
					bs_v2004 = bs_v333(bs_v1935, bs_v1929, bs_v1956)

					if bs_v2001 > 0.01 then
						render.rect(vector(bs_v1998 - 2, bs_v1983 - 2), vector(bs_v1994 + 2, bs_v1989 + 2), color(bs_v2004.r, bs_v2004.g, bs_v2004.b, math.floor(bs_v1939 * 0.2 * bs_v2001)), bs_v93 + 1)
					end
				end
			end
		end

		if not bs_v1954 then
			bs_v1995 = math.floor(bs_v1993 * bs_v1960)

			if bs_v1995 > 1 then
				bs_v1997 = bs_v1994 + bs_v1995

				if bs_v1970 > 0.01 then
					render.rect(vector(bs_v1994, bs_v1983), vector(bs_v1997, bs_v1989), color(255, 255, 255, math.floor(bs_v1939 * 0.45 * bs_v1970)), bs_v93)
				end

				if bs_v1960 >= 0.97 then
					bs_v2000 = (math.sin(bs_v1893 * 3.2 + 1.57) + 1) * 0.5
					bs_v1999 = bs_v2000 * bs_v2000
					bs_v2003 = bs_v333(bs_v1935, bs_v1933, bs_v1960)

					if bs_v1999 > 0.01 then
						render.rect(vector(bs_v1994 - 2, bs_v1983 - 2), vector(bs_v1997 + 2, bs_v1989 + 2), color(bs_v2003.r, bs_v2003.g, bs_v2003.b, math.floor(bs_v1939 * 0.2 * bs_v1999)), bs_v93 + 1)
					end
				end
			end
		end

		render.rect(vector(bs_v1992, bs_v1983 - 1), vector(bs_v1992 + 1, bs_v1989 + 1), color(255, 255, 255, math.floor(bs_v1939 * 0.55)), 0)
	end

	if bs_v320.active and bs_v320.alpha.value > 0.01 then
		bs_v1938 = math.floor(bs_v320.alpha.value * 255)
		bs_v1940 = math.floor(bs_v1936.y - bs_v1988 * 0.5)
		bs_v1942 = bs_v320.col_is_def and bs_v1933 or bs_v1929
		bs_v1944 = bs_v320.fill
		bs_v1946 = bs_v320.rem

		if bs_v1891 then
			bs_v1944 = bs_v280.value
			bs_v1946 = bs_v1944 * bs_v320.reset
		end

		bs_v360(bs_v320.anim, bs_v1944, 0.1, bs_v1889)

		bs_v1948 = math.max(0, math.min(1, bs_v320.anim.value))

		if bs_v320.prev_f < 0.97 and bs_v1948 >= 0.97 then
			bs_v320.shim_t = bs_v1893
		end

		bs_v320.prev_f = bs_v1948
		bs_v1950 = math.max(0, math.min(1, (bs_v1893 - bs_v320.shim_t) / 0.55))
		bs_v1953 = bs_v1950 < 1 and math.sin(bs_v1950 * math.pi) or 0
		bs_v1955 = bs_v333(bs_v1935, bs_v1942, bs_v1948)

		if bs_v1914 then
			bs_v1959 = render.measure_text(bs_v192, nil, "bruteforce")

			render.text(bs_v192, vector(bs_v1937 - math.floor(bs_v1959.x * 0.5), bs_v1940), color(105, 105, 110, math.floor(bs_v1938 * 0.78)), nil, "bruteforce")

			bs_v1940 = bs_v1940 + bs_v1902 + bs_v107
		end

		if bs_v1934 then
			bs_v1958 = ("%.1fs"):format(bs_v1946)
			bs_v1962 = render.measure_text(bs_v192, nil, bs_v1958)
			bs_v1965 = bs_v333(color(105, 105, 110, 255), bs_v1942, bs_v1948)

			render.text(bs_v192, vector(bs_v1937 - math.floor(bs_v1962.x * 0.5) + 1, bs_v1940 + 1), color(0, 0, 0, math.floor(bs_v1938 * 0.18)), nil, bs_v1958)
			render.text(bs_v192, vector(bs_v1937 - math.floor(bs_v1962.x * 0.5), bs_v1940), color(bs_v1965.r, bs_v1965.g, bs_v1965.b, math.floor(bs_v1938 * 0.88)), nil, bs_v1958)

			bs_v1940 = bs_v1940 + bs_v1902
		end

		bs_v1957 = bs_v1937 - math.floor(bs_v57 * 0.5)
		bs_v1961 = bs_v1957 + bs_v57
		bs_v1964 = bs_v1940 + (bs_v1952 > 0 and bs_v124 or 0)
		bs_v1967 = bs_v1964 + bs_v76

		render.rect(vector(bs_v1957, bs_v1964), vector(bs_v1961, bs_v1967), color(255, 255, 255, math.floor(bs_v1938 * 0.09)), bs_v93)

		bs_v1969 = math.floor(bs_v57 * bs_v1948)

		if bs_v1969 > 1 then
			bs_v1971 = bs_v1957 + bs_v1969
			bs_v1975 = math.floor(bs_v1938 * 0.16 * bs_v1948)

			if bs_v1975 > 2 then
				render.rect(vector(bs_v1957, bs_v1964 - 1), vector(bs_v1971, bs_v1967 + 2), color(bs_v1955.r, bs_v1955.g, bs_v1955.b, bs_v1975), bs_v93)
			end

			render.rect(vector(bs_v1957, bs_v1964), vector(bs_v1971, bs_v1967), color(bs_v1955.r, bs_v1955.g, bs_v1955.b, math.floor(bs_v1938 * 0.88)), bs_v93)
			render.rect(vector(bs_v1957, bs_v1964), vector(bs_v1971, bs_v1964 + math.ceil(bs_v76 * 0.5)), color(255, 255, 255, math.floor(bs_v1938 * 0.16)), bs_v93)

			if bs_v1953 > 0.01 then
				render.rect(vector(bs_v1957, bs_v1964), vector(bs_v1971, bs_v1967), color(255, 255, 255, math.floor(bs_v1938 * 0.45 * bs_v1953)), bs_v93)
			end

			if bs_v1948 >= 0.97 then
				bs_v1982 = (math.sin(bs_v1893 * 3.2) + 1) * 0.5
				bs_v1981 = bs_v1982 * bs_v1982

				if bs_v1981 > 0.01 then
					render.rect(vector(bs_v1957 - 2, bs_v1964 - 2), vector(bs_v1971 + 2, bs_v1967 + 2), color(bs_v1955.r, bs_v1955.g, bs_v1955.b, math.floor(bs_v1938 * 0.2 * bs_v1981)), bs_v93 + 1)
				end
			end
		end
	end
end)

bs_v56 = nil
bs_v71 = "ground"
bs_v92 = 0
bs_v101 = {}
bs_v123 = 0
bs_v141 = false
bs_v160 = 3
bs_v168 = 0
bs_v211 = 0

function bs_v230()
	bs_v71 = "ground"
	bs_v92 = 0
	bs_v160 = 3
	bs_v168 = 0
	bs_v211 = 0
	bs_v101 = {}
	bs_v123 = 0
	bs_v141 = false
	bs_defensive_mgr.head_vuln_ticks = 0

	pcall(function()
		bs_config.antiaim.fake_lag.limit:override()
		bs_config.rage.main.double_tap_lag_options:override()
	end)
end

events.createmove(function()
	local var_549_0 = entity.get_local_player()

	if not var_549_0 or not var_549_0:is_alive() then
		bs_v230()

		return
	end

	local var_549_1, var_549_2 = pcall(function()
		return bs_config.rage.main.double_tap:get()
	end)
	local var_549_3 = var_549_1 and var_549_2
	local var_549_4 = 14
	local var_549_5 = 6
	local var_549_6 = 14
	local var_549_7 = var_549_0.m_fFlags
	local var_549_8 = var_549_7 == 257 or var_549_7 == 263

	if bs_v141 then
		bs_v123 = bs_v123 + 1
	end

	if bs_v211 > 0 then
		bs_v211 = bs_v211 - 1
	end

	if var_549_8 then
		bs_v160 = bs_v160 + 1

		if bs_v71 ~= "ground" then
			bs_v168 = 0
		end

		bs_v71 = "ground"
		bs_v92 = 0
		bs_v141 = false
	else
		if bs_v71 == "ground" then
			local var_549_9 = bs_v160 <= 3

			bs_v160 = 0
			bs_v71 = "air"
			bs_v92 = 1
			bs_v123 = 0
			bs_v141 = true
			bs_v101 = {}

			if var_549_9 and bs_v211 == 0 then
				bs_v168 = var_549_4
			else
				bs_v168 = 0
			end
		else
			bs_v92 = bs_v92 + 1
		end

		if bs_v168 > 0 and var_549_3 then
			if bs_defensive_mgr.is_active and bs_v168 <= var_549_4 - var_549_5 then
				bs_v168 = 0
				bs_v211 = var_549_6
			else
				bs_v168 = bs_v168 - 1
			end
		end
	end

	if not bs_def_snap.active and not bs_defensive_mgr.is_active and not bs_break_lc.should_force() then
		bs_config.antiaim.fake_lag.limit:override()
		bs_config.rage.main.double_tap_lag_options:override()
	end

	bs_defensive_mgr.head_vuln_ticks = bs_v168
end)
events.level_change(bs_v230)
events.round_start(bs_v230)

bs_v70 = nil

function bs_v85(arg_551_0, arg_551_1)
	if not bs_menu.misc.movement.fall_damage:get() then
		return false
	end

	local var_551_0 = arg_551_0:get_origin()
	local var_551_1 = math.pi

	for iter_551_0 = 0, var_551_1 * 2, var_551_1 / 4 do
		if utils.trace_line(var_551_0, var_551_0 + vector(10 * math.cos(iter_551_0), 10 * math.sin(iter_551_0), -arg_551_1), arg_551_0).fraction < 0.9921875 then
			return true
		end
	end

	return false
end

events.createmove(function(arg_552_0)
	if not bs_menu.misc.movement.fall_damage:get() then
		return false
	end

	local var_552_0 = entity.get_local_player()

	if var_552_0 == nil or not var_552_0:is_alive() then
		return
	end

	if var_552_0.m_vecVelocity.z >= -500 then
		return
	end

	arg_552_0.in_duck = not bs_v85(var_552_0, 15) and bs_v85(var_552_0, 75)
end)

bs_v84 = nil

events.createmove(function(arg_553_0)
	if not bs_menu.misc.movement.fast_ladder:get() then
		return
	end

	if arg_553_0.in_use then
		return
	end

	local var_553_0 = entity.get_local_player()

	if var_553_0 == nil or not var_553_0:is_alive() then
		return
	end

	if var_553_0.m_MoveType ~= 9 then
		return
	end

	local var_553_1 = var_553_0:get_player_weapon()

	if var_553_1 == nil or var_553_1.m_bPinPulled then
		return
	end

	if render.camera_angles().x < 45 and arg_553_0.forwardmove ~= 0 then
		local var_553_2 = arg_553_0.forwardmove > 0

		arg_553_0.view_angles.x = 89
		arg_553_0.in_forward = not var_553_2
		arg_553_0.in_back = var_553_2
		arg_553_0.in_moveleft = not var_553_2
		arg_553_0.in_moveright = var_553_2

		if arg_553_0.sidemove == 0 then
			arg_553_0.view_angles.y = arg_553_0.view_angles.y + 90
		elseif arg_553_0.sidemove < 0 then
			arg_553_0.view_angles.y = arg_553_0.view_angles.y + (var_553_2 and 150 or 30)
		elseif arg_553_0.sidemove > 0 then
			arg_553_0.view_angles.y = arg_553_0.view_angles.y + (var_553_2 and 30 or 150)
		end
	end
end)

bs_v100 = nil
bs_v116 = {}
bs_v140 = {}
bs_v159 = render.load_font("Verdana", 14, "ab")
bs_v189 = "✦"

events.createmove(function(arg_554_0)
	if not bs_menu.misc.drink.enabled:get() then
		bs_v116 = {}

		return
	end

	if entity.get_threat(true) then
		bs_v116 = {}

		return
	end

	local var_554_0 = entity.get_local_player()

	if not var_554_0 or not var_554_0:is_alive() then
		bs_v116 = {}

		return
	end

	bs_v116 = {}

	if var_554_0.m_iHealth > 100 then
		return
	end

	local var_554_1 = var_554_0:get_eye_position()
	local var_554_2 = entity.get_entities("CPhysicsProp")
	local var_554_3 = false

	if arg_554_0.choked_commands == 0 then
		var_554_3 = true
	end

	for iter_554_0 = 1, #var_554_2 do
		local var_554_4 = var_554_2[iter_554_0]

		if not var_554_4 then
			-- block empty
		else
			local var_554_5 = var_554_4:get_origin()
			local var_554_6 = var_554_1:dist(var_554_5)

			bs_v116[iter_554_0] = var_554_5

			if var_554_6 > 88 then
				-- block empty
			else
				local var_554_7 = utils.trace_line(var_554_1, var_554_5, var_554_0)

				if not var_554_7.entity or var_554_7.entity:get_index() == 0 then
					-- block empty
				else
					local var_554_8 = var_554_1:to(var_554_5):angles()

					if var_554_3 then
						var_554_3 = false
						arg_554_0.no_choke = true
						arg_554_0.view_angles = var_554_8
						arg_554_0.in_use = true
					end
				end
			end
		end
	end
end)
events.render(function()
	if not bs_menu.misc.drink.enabled:get() then
		return
	end

	if not bs_menu.misc.drink.esp:get() then
		return
	end

	local var_555_0 = entity.get_local_player()

	if not var_555_0 or not var_555_0:is_alive() then
		return
	end

	local var_555_1 = var_555_0:get_eye_position()
	local var_555_2 = bs_menu.misc.drink.esp_color:get()
	local var_555_3 = bs_menu.misc.drink.distance:get()
	local var_555_4 = globals.realtime
	local var_555_5 = #bs_v116

	for iter_555_0 in pairs(bs_v140) do
		if var_555_5 < iter_555_0 then
			bs_v140[iter_555_0] = nil
		end
	end

	for iter_555_1 = 1, var_555_5 do
		local var_555_6 = bs_v116[iter_555_1]

		if not var_555_6 then
			-- block empty
		else
			local var_555_7 = var_555_1:dist(var_555_6)
			local var_555_8 = 1

			if var_555_7 > var_555_3 * 0.6 then
				var_555_8 = math.max(0, 1 - (var_555_7 - var_555_3 * 0.6) / (var_555_3 * 0.4))
			end

			if var_555_3 < var_555_7 then
				var_555_8 = 0
			end

			if not bs_v140[iter_555_1] then
				bs_v140[iter_555_1] = {
					alpha = 0,
					breath_off = math.random() * math.pi * 2,
					ping_phase = iter_555_1 * 0.73 % 1
				}
			end

			local var_555_9 = bs_v140[iter_555_1]
			local var_555_10 = var_555_8 > var_555_9.alpha and 0.08 or 0.04

			var_555_9.alpha = var_555_9.alpha + (var_555_8 - var_555_9.alpha) * var_555_10

			local var_555_11 = var_555_9.alpha

			if var_555_11 < 0.008 then
				-- block empty
			else
				local var_555_12 = render.world_to_screen(var_555_6)

				if not var_555_12 then
					-- block empty
				else
					local var_555_13 = var_555_2.a / 255
					local var_555_14 = (math.sin(var_555_4 * 1.4 + var_555_9.breath_off) + 1) * 0.5
					local var_555_15 = math.floor(var_555_13 * var_555_11 * (0.7 + var_555_14 * 0.3) * 255)

					if var_555_15 > 4 then
						local var_555_16 = render.measure_text(bs_v159, nil, bs_v189)
						local var_555_17 = math.floor(var_555_12.x - var_555_16.x * 0.5)
						local var_555_18 = math.floor(var_555_12.y - var_555_16.y * 0.5)
						local var_555_19 = math.floor(var_555_15 * 0.25)

						if var_555_19 > 2 then
							render.text(bs_v159, vector(var_555_17 + 1, var_555_18 + 1), color(0, 0, 0, var_555_19), nil, bs_v189)
						end

						render.text(bs_v159, vector(var_555_17, var_555_18), color(var_555_2.r, var_555_2.g, var_555_2.b, var_555_15), nil, bs_v189)
					end
				end
			end
		end
	end
end)

bs_v115 = nil
bs_v132 = ffi.typeof("        struct {\n            char  pad_0000[20];\n            int m_nOrder;\n            int m_nSequence;\n            float m_flPrevCycle;\n            float m_flWeight;\n            float m_flWeightDeltaRate;\n            float m_flPlaybackRate;\n            float m_flCycle;\n            void *m_pOwner;\n            char  pad_0038[4];\n        } **\n    ")
bs_v158 = 0
bs_v188 = 0

function bs_v210(arg_556_0)
	local var_556_0 = entity.get_local_player()

	if var_556_0 == nil then
		return
	end

	if arg_556_0 ~= var_556_0 then
		return
	end

	local var_556_1 = bs_menu.misc.movement.anim_breaker

	if not var_556_1:get() then
		return
	end

	local var_556_2 = bs_menu.misc.movement.types
	local var_556_3 = bit.band(var_556_0.m_fFlags, 1) == 1

	if not var_556_3 and var_556_2:get("in air") then
		local var_556_4 = bs_menu.misc.movement.in_air_type:get()

		if var_556_4 == "static" then
			var_556_0.m_flPoseParameter[6] = 0.6
		elseif var_556_4 == "reverse running" then
			pcall(function()
				ffi.cast(bs_v132, ffi.cast("uintptr_t", arg_556_0[0]) + 10640)[0][6].m_flWeight = 0.8
			end)
		end
	elseif var_556_3 and var_556_2:get("on ground") then
		local var_556_5 = bs_menu.misc.movement.on_ground_type:get()

		if var_556_5 == "static" then
			var_556_0.m_flPoseParameter[0] = math.max(-1, math.min(1, 1))

			bs_config.antiaim.misc.leg_movement:override("Sliding")
		elseif var_556_5 == "jitter" then
			var_556_0.m_flPoseParameter[globals.client_tick % 3] = math.max(-1, math.min(1, 0.8))

			bs_config.antiaim.misc.leg_movement:override("Sliding")
		elseif var_556_5 == "reverse running" then
			var_556_0.m_flPoseParameter[7] = math.max(0, math.min(1, 0.5))

			bs_config.antiaim.misc.leg_movement:override("Walking")
		end
	end

	if var_556_2:get("pitch zero on land") then
		if var_556_3 then
			bs_v158 = bs_v158 + 1
		else
			bs_v158 = 0
			bs_v188 = globals.curtime + 1
		end

		if bs_v158 > 15 and bs_v188 > globals.curtime then
			var_556_0.m_flPoseParameter[12] = math.max(0, math.min(1, 0.5))
		end
	end
end

events.post_update_clientside_animation(function(arg_558_0)
	if not arg_558_0 or arg_558_0[0] == nil then
		return
	end

	bs_v210(arg_558_0)
end)

-- ===== STRAIGHT THROW (SUPER TOSS) =====
-- Ported from open_source_luas/supertoss.lua (CSGO-HVH-LUAS). When holding a
-- grenade (weapon_type 9) the throw angle is compensated for the player's
-- current velocity so the nade flies where you aim, while the on-screen view
-- stays locked to the real camera angle. Gated by the Movement & Animation
-- "Straight Throw (Super Toss)" switch.
bs_super_toss = {
	active = false,
	last_angles = vector(0, 0, 0),
	target_angles = vector(0, 0, 0),
}

function bs_super_toss.check_active()
	bs_super_toss.active = false

	local menu = bs_menu.misc.movement.super_toss

	if not menu or not menu:get() then
		return
	end

	local local_player = entity.get_local_player()

	if not local_player or not local_player:is_alive() then
		return
	end

	if local_player.m_MoveType == 8 then
		return
	end

	local weapon = local_player:get_player_weapon()

	if not weapon then
		return
	end

	local ok, weapon_info = pcall(function()
		return weapon:get_weapon_info()
	end)

	if not ok or not weapon_info then
		return
	end

	if weapon_info.weapon_type ~= 9 then
		return
	end

	bs_super_toss.active = true
end

function bs_super_toss.ang_vec(ang)
	return vector(
		math.cos(ang.x * math.pi / 180) * math.cos(ang.y * math.pi / 180),
		math.cos(ang.x * math.pi / 180) * math.sin(ang.y * math.pi / 180),
		-math.sin(ang.x * math.pi / 180)
	)
end

events.pre_render(function()
	bs_super_toss.check_active()
	bs_super_toss.last_angles = render.camera_angles()

	if bs_super_toss.active and not common.is_in_thirdperson() then
		render.camera_angles(bs_super_toss.target_angles)
	end
end)

events.override_view(function(arg_102_0)
	if not bs_super_toss.active then
		return
	end

	arg_102_0.view = bs_super_toss.last_angles
	render.camera_angles(bs_super_toss.last_angles)
end)

events.createmove(function(arg_102_1)
	if not bs_super_toss.active then
		return
	end

	local local_player = entity.get_local_player()

	if not local_player or not local_player:is_alive() then
		return
	end

	local weapon = local_player:get_player_weapon()

	if not weapon then
		return
	end

	local ok, weapon_info = pcall(function()
		return weapon:get_weapon_info()
	end)

	if not ok or not weapon_info then
		return
	end

	local ang_throw = vector(arg_102_1.view_angles.x, arg_102_1.view_angles.y, 0)

	ang_throw.x = ang_throw.x - (90 - math.abs(ang_throw.x)) * 10 / 90
	ang_throw = bs_super_toss.ang_vec(ang_throw)

	local throw_strength = math.clamp(weapon.m_flThrowStrength, 0, 1)
	local fl_velocity = math.clamp(weapon_info.throw_velocity * 0.9, 15, 750)

	fl_velocity = fl_velocity * (throw_strength * 0.7 + 0.3)

	local localplayer_velocity = local_player.m_vecVelocity or vector(0, 0, 0)
	local vec_throw = ang_throw * fl_velocity + localplayer_velocity * 1.45

	vec_throw = vec_throw:angles()

	local yaw_difference = arg_102_1.view_angles.y - vec_throw.y

	while yaw_difference > 180 do
		yaw_difference = yaw_difference - 360
	end

	while yaw_difference < -180 do
		yaw_difference = yaw_difference + 360
	end

	local pitch_difference = arg_102_1.view_angles.x - vec_throw.x - 10

	while pitch_difference > 90 do
		pitch_difference = pitch_difference - 45
	end

	while pitch_difference < -90 do
		pitch_difference = pitch_difference + 45
	end

	bs_super_toss.target_angles.y = arg_102_1.view_angles.y + yaw_difference
	arg_102_1.view_angles.y = arg_102_1.view_angles.y + yaw_difference
	bs_super_toss.target_angles.x = math.clamp(arg_102_1.view_angles.x + pitch_difference, -89, 89)
	arg_102_1.view_angles.x = math.clamp(arg_102_1.view_angles.x + pitch_difference, -89, 89)
end)

bs_v131 = nil
bs_v149 = "✦"
bs_v187 = render.load_font("Verdana", 10, "ab")
bs_v209 = {}
bs_v229 = 0
bs_v250 = {}

function bs_v268(arg_559_0)
	arg_559_0 = 1 - arg_559_0

	return 1 - arg_559_0 * arg_559_0 * arg_559_0
end

events.player_hurt(function(arg_560_0)
	if arg_560_0.health <= 0 then
		local var_560_0 = entity.get_local_player()
		local var_560_1 = var_560_0 and entity.get(arg_560_0.attacker, true)

		if var_560_1 and var_560_0 and var_560_1:get_index() == var_560_0:get_index() then
			local var_560_2 = entity.get(arg_560_0.userid, true)

			if var_560_2 then
				bs_v250[var_560_2:get_index()] = true
			end
		end
	end
end)
events.aim_ack(function(arg_561_0)
	local var_561_0 = bs_menu.info.hitmarker

	if not var_561_0 or not var_561_0.enabled:get() then
		return
	end

	local var_561_1 = entity.get_local_player()

	if var_561_1 == nil or not var_561_1:is_alive() then
		return
	end

	local var_561_2 = arg_561_0.aim

	if not var_561_2 or var_561_2.x == nil then
		return
	end

	local var_561_3 = arg_561_0.state == nil
	local var_561_4 = false

	if var_561_3 and arg_561_0.target then
		local var_561_5 = arg_561_0.target:get_index()

		if bs_v250[var_561_5] then
			var_561_4 = true
			bs_v250[var_561_5] = nil
		end
	end

	bs_v229 = bs_v229 + 1
	bs_v209[bs_v229] = {
		fade = 1,
		pos = vector(var_561_2.x, var_561_2.y, var_561_2.z),
		is_hit = var_561_3,
		is_kill = var_561_4
	}
end)
events.render(function()
	bs_v2008 = bs_menu.info.hitmarker

	if not bs_v2008 or not bs_v2008.enabled:get() then
		return
	end

	bs_v2009 = bs_v2008.duration:get()

	if bs_v2009 <= 0 then
		bs_v209 = {}

		return
	end

	bs_v2024 = globals.frametime

	for iter_562_0, iter_562_1 in pairs(bs_v209) do
		iter_562_1.fade = iter_562_1.fade - bs_v2024 / bs_v2009

		if iter_562_1.fade <= 0 then
			bs_v209[iter_562_0] = nil
		else
			bs_v2026 = render.world_to_screen(iter_562_1.pos)

			if bs_v2026 then
				bs_v2027 = iter_562_1.fade
				bs_v2010 = bs_v2027 < 0.25 and bs_v2027 / 0.25 or 1
				bs_v2011 = nil

				if iter_562_1.is_kill then
					bs_v2011 = bs_v2008.col_kill:get()
				elseif iter_562_1.is_hit then
					bs_v2011 = bs_v2008.col_hit:get()
				else
					bs_v2011 = bs_v2008.col_miss:get()
				end

				bs_v2012 = bs_v2011.a
				bs_v2013 = color(bs_v2011.r, bs_v2011.g, bs_v2011.b, math.min(255, math.floor(bs_v2012 * bs_v2010)))

				if bs_v2013.a > 0 then
					bs_v2015 = render.measure_text(bs_v187, nil, bs_v149)
					bs_v2017 = (bs_v2008.size and bs_v2008.size:get() or 18) / 18
					bs_v2018 = bs_v2015.x * 0.5 * bs_v2017
					bs_v2020 = bs_v2015.y * 0.5 * bs_v2017
					bs_v2022 = math.floor(bs_v2013.a * 0.5)
					bs_v2023 = math.max(2, math.floor(3 * bs_v2017))

					if bs_v2022 > 4 then
						bs_v2025 = color(bs_v2013.r, bs_v2013.g, bs_v2013.b, bs_v2022)

						for iter_562_2, iter_562_3 in ipairs({
							{
								-bs_v2023,
								0
							},
							{
								bs_v2023,
								0
							},
							{
								0,
								-bs_v2023
							},
							{
								0,
								bs_v2023
							}
						}) do
							render.text(bs_v187, vector(bs_v2026.x - bs_v2018 + iter_562_3[1], bs_v2026.y - bs_v2020 + iter_562_3[2]), bs_v2025, nil, bs_v149)
						end
					end

					render.text(bs_v187, vector(bs_v2026.x - bs_v2018, bs_v2026.y - bs_v2020), bs_v2013, nil, bs_v149)
				end

				if bs_v2008.explode_effect and bs_v2008.explode_effect:get() then
					bs_v2014 = 1 - bs_v2027
					bs_v2016 = math.min(1, bs_v2014 * 6)
					bs_v2019 = ((iter_562_1.is_hit or iter_562_1.is_kill) and 26 or 13) * bs_v2016
					bs_v2021 = math.floor((1 - bs_v2016) * 81)

					if bs_v2019 >= 0.5 and bs_v2021 > 0 then
						render.circle(vector(bs_v2026.x, bs_v2026.y), color(255, 255, 255, bs_v2021), math.max(1, math.floor(bs_v2019)), 0, 1)
					end

					render.circle(vector(bs_v2026.x, bs_v2026.y), color(255, 255, 255, 54), 2, 0, 1)
				end
			end
		end
	end
end)
events.round_start(function()
	bs_v209 = {}
	bs_v229 = 0
	bs_v250 = {}
end)
events.player_spawned(function()
	bs_v209 = {}
	bs_v229 = 0
	bs_v250 = {}
end)
events.level_change(function()
	bs_v209 = {}
	bs_v229 = 0
	bs_v250 = {}
end)

bs_v148 = nil
bs_v186 = render.load_font("Tahoma Bold", vector(0, 13, 0), "ab")
bs_v208 = {}
bs_v228 = 0.55
bs_v249 = 2.2
bs_v267 = 31

events.aim_ack(function(arg_566_0)
	local var_566_0 = bs_menu.info.hitmarker

	if not var_566_0 or not var_566_0.dm_enabled:get() then
		return
	end

	local var_566_1 = entity.get_local_player()

	if var_566_1 == nil or not var_566_1:is_alive() then
		return
	end

	if arg_566_0.state ~= nil then
		return
	end

	local var_566_2 = arg_566_0.aim

	if not var_566_2 or var_566_2.x == nil then
		return
	end

	local var_566_3 = arg_566_0.damage or 0

	if var_566_3 <= 0 then
		return
	end

	local var_566_4 = false

	if arg_566_0.target then
		local var_566_5, var_566_6 = pcall(function()
			return arg_566_0.target.m_iHealth
		end)

		if var_566_5 and var_566_6 and var_566_6 <= 0 then
			var_566_4 = true
		end
	end

	bs_v208[#bs_v208 + 1] = {
		t = 0,
		pos = vector(var_566_2.x, var_566_2.y, var_566_2.z),
		target = var_566_3,
		is_kill = var_566_4
	}
end)
events.render(function()
	local var_568_0 = bs_menu.info.hitmarker

	if not var_568_0 or not var_568_0.dm_enabled:get() then
		bs_v208 = {}

		return
	end

	local var_568_1 = globals.frametime

	for iter_568_0 = #bs_v208, 1, -1 do
		local var_568_2 = bs_v208[iter_568_0]

		var_568_2.t = var_568_2.t + var_568_1

		if var_568_2.t >= bs_v249 then
			table.remove(bs_v208, iter_568_0)
		else
			local var_568_3 = math.min(1, var_568_2.t / bs_v228)
			local var_568_4

			if var_568_3 < 1 then
				local var_568_5 = 1 - var_568_3

				var_568_4 = 1 - var_568_5 * var_568_5 * var_568_5 * var_568_5
			else
				var_568_4 = 1
			end

			local var_568_6 = math.floor(var_568_2.target * var_568_4 + 0.5)
			local var_568_7 = tostring(var_568_6)
			local var_568_8 = render.world_to_screen(var_568_2.pos)

			if var_568_8 then
				local var_568_9 = math.min(1, var_568_2.t / bs_v249 * 1.6)
				local var_568_10 = var_568_9 * var_568_9 * (3 - 2 * var_568_9)
				local var_568_11 = var_568_2.t / bs_v249
				local var_568_12

				if var_568_11 < 0.07 then
					var_568_12 = var_568_11 / 0.07
				elseif var_568_11 < 0.7 then
					var_568_12 = 1
				else
					local var_568_13 = (var_568_11 - 0.7) / 0.3

					var_568_12 = 1 - var_568_13 * var_568_13 * (3 - 2 * var_568_13)
				end

				local var_568_14 = math.max(0, var_568_12)
				local var_568_15 = var_568_2.is_kill and var_568_0.dm_col_kill:get() or var_568_0.dm_col_hit:get()
				local var_568_16 = math.min(255, math.floor(var_568_15.a * var_568_14 * 2))
				local var_568_17 = color(var_568_15.r, var_568_15.g, var_568_15.b, var_568_16)
				local var_568_18 = render.measure_text(bs_v186, nil, var_568_7)
				local var_568_19 = math.floor(var_568_8.x - var_568_18.x * 0.5)
				local var_568_20 = math.floor(var_568_8.y - var_568_10 * bs_v267)
				local var_568_21 = math.floor(var_568_16 * 0.65)

				if var_568_21 > 2 then
					render.text(bs_v186, vector(var_568_19 + 1, var_568_20 + 1), color(0, 0, 0, var_568_21), nil, var_568_7)
				end

				render.text(bs_v186, vector(var_568_19, var_568_20), var_568_17, nil, var_568_7)
			end
		end
	end
end)
events.round_start(function()
	bs_v208 = {}
end)
events.player_spawned(function()
	bs_v208 = {}
end)

bs_v185 = {
	{
		"1"
	},
	{
		"wyd",
		"?"
	},
	{
		"hs"
	},
	{
		"1",
		"?"
	},
	{
		"xddd",
		"1"
	},
	{
		"baited",
		"bot"
	},
	{
		"1",
		"bot"
	},
	{
		"too slow"
	}
}
bs_v207 = nil
bs_v227 = nil
bs_v248 = nil
bs_v266 = nil

function bs_v279(arg_571_0)
	local var_571_0 = 1 + #arg_571_0 / 10 * 2
	local var_571_1 = (math.random() - 0.5) * 0.6

	return math.max(1, math.min(4, var_571_0 + var_571_1))
end

function bs_v294()
	local var_572_0

	repeat
		var_572_0 = math.random(1, #bs_v185)
	until var_572_0 ~= bs_v248

	bs_v248 = var_572_0

	local var_572_1 = bs_v185[var_572_0]
	local var_572_2 = bs_v279(var_572_1[1])

	bs_v207 = {
		text = var_572_1[1],
		time = globals.realtime + var_572_2,
		next = var_572_1[2]
	}
end

function bs_v307()
	local var_573_0 = 1 + math.random() * 0.8

	bs_v207 = {
		text = "ofc body u fkn nn xd",
		time = globals.realtime + var_573_0
	}
end

events.net_update_end(function()
	if bs_v207 and globals.realtime >= bs_v207.time then
		utils.console_exec("say \"" .. bs_v207.text .. "\"")

		local var_574_0 = bs_v207.next

		bs_v207 = nil

		if var_574_0 then
			local var_574_1 = 1.2 + math.random() * 0.8

			bs_v207 = {
				text = var_574_0,
				time = globals.realtime + var_574_1
			}
		end
	end
end)
events.round_start(function()
	bs_v227 = nil
	bs_v266 = nil
end)
events.level_change(function()
	bs_v227 = nil
	bs_v207 = nil
	bs_v266 = nil
end)
events.player_hurt(function(arg_577_0)
	local var_577_0 = entity.get_local_player()

	if not var_577_0 then
		return
	end

	if entity.get(arg_577_0.userid, true) == var_577_0 then
		bs_v266 = arg_577_0.hitgroup
	end
end)
events.player_death(function(arg_578_0)
	local var_578_0 = bs_menu.misc.killsay

	if not var_578_0 or not var_578_0.enabled:get() then
		return
	end

	if arg_578_0.userid == arg_578_0.attacker then
		return
	end

	local var_578_1 = entity.get_local_player()

	if not var_578_1 then
		return
	end

	local var_578_2 = entity.get(arg_578_0.attacker, true)
	local var_578_3 = entity.get(arg_578_0.userid, true)

	if var_578_2 == var_578_1 and var_578_0.modes:get("kill") then
		bs_v294()
	end

	if var_578_3 == var_578_1 and var_578_2 ~= var_578_1 then
		local var_578_4 = arg_578_0.weapon or ""
		local var_578_5 = var_578_4 == "hegrenade" or var_578_4 == "inferno" or var_578_4 == "molotov" or var_578_4 == "decoy" or var_578_4 == "flashbang" or var_578_4 == "smokegrenade" or var_578_4 == "tagrenade" or var_578_4 == "firebomb" or var_578_4 == "diversion" or var_578_4 == "taser"
		local var_578_6 = var_578_4:find("knife") or var_578_4:find("bayonet") or var_578_4 == "knifegg"

		if not var_578_5 and not var_578_6 and bs_v266 ~= nil and bs_v266 ~= 1 then
			bs_v307()
		end

		bs_v227 = arg_578_0.attacker
	end

	if bs_v227 and arg_578_0.userid == bs_v227 and var_578_2 ~= var_578_1 and var_578_0.modes:get("revenge") then
		bs_v294()

		bs_v227 = nil
	end
end)

bs_v184 = "bluesense"
	bs_v226 = nil
bs_v247, bs_v265 = pcall(function()
	return ui.find("Miscellaneous", "Main", "Other", "Clan Tag")
end)

if bs_v247 then
	bs_v226 = bs_v265
end

function bs_v246(arg_580_0)
	if bs_v226 then
		pcall(function()
			bs_v226:override(true)
		end)
	end

	pcall(function()
		common.set_clan_tag(arg_580_0)
	end)
end

function bs_v264()
	if bs_v226 then
		pcall(function()
			bs_v226:override()
		end)
	end

	pcall(function()
		common.set_clan_tag("")
	end)
end

bs_v278 = nil
	bs_v293 = 0
	bs_v306 = 0
	bs_v319 = 0.35
	bs_v332 = ""
	bs_v345 = {}
	bs_v359 = #bs_v184

	-- Write phase: grow one character at a time
	for iter_0_40 = 1, bs_v359 do
		bs_v345[#bs_v345 + 1] = bs_v184:sub(1, iter_0_40)
	end

	-- Full text
	bs_v345[#bs_v345 + 1] = bs_v184

	-- Delete phase: shrink one character at a time
	for iter_0_40 = bs_v359 - 1, 1, -1 do
		bs_v345[#bs_v345 + 1] = bs_v184:sub(1, iter_0_40)
	end

	bs_v358 = #bs_v345

events.render(function()
	local var_586_0 = bs_menu.misc.clantag

	if not var_586_0 then
		return
	end

	if not var_586_0.enabled:get() then
		if bs_v278 then
			bs_v264()

			bs_v278 = false
			bs_v332 = ""
		end

		return
	end

	bs_v278 = true

	-- Sync the scroll to the server tick so every bluesense user shows the same
	-- frame at the same time (frametime-based timing desynced between users).
	local var_586_2 = math.floor(globals.tickcount / math.max(1, math.floor(bs_v319 / globals.tickinterval + 0.5))) % bs_v358 + 1

	if var_586_2 ~= bs_v306 then
		bs_v306 = var_586_2

		local var_586_1 = bs_v345[bs_v306]

		if var_586_1 ~= bs_v332 then
			bs_v332 = var_586_1

			bs_v246(var_586_1)
		end
	end
end)
events.level_change(function()
	bs_v278 = nil
	bs_v306 = 0
	bs_v293 = 0
	bs_v332 = ""
end)
events.shutdown(bs_v264)

-- ===== AIR EXPLOIT (LCHub-style lag-comp break) =====
-- Ported from open_source_luas/SKEET-KILLEREXPLOITLCHub_oracle.lua. While
-- airborne it abuses sv_maxusrcmdprocessticks + Double Tap charge/teleport +
-- fake duck to break lag compensation. Gated by the anti-aim "Air Exploit
-- (Lag Comp)" switch placed below Force Defensive. Registered late so its
-- overrides win over the AA builder's, and fully resets on disable/shutdown.
bs_air_exploit = {
	active = false,
	cmd_ticks = cvar.sv_maxusrcmdprocessticks,
	orig_ticks = nil,
}

pcall(function()
	bs_air_exploit.orig_ticks = cvar.sv_maxusrcmdprocessticks:int()
end)

function bs_air_exploit.find_handle(path)
	local ok, handle = pcall(function()
		return ui.find(unpack(path))
	end)

	if ok then
		return handle
	end

	return nil
end

bs_air_exploit.h = {
	dt = bs_config.rage.main.double_tap,
	dt_lag = bs_config.rage.main.double_tap_lag_options,
	dt_immediate = bs_air_exploit.find_handle({ "Aimbot", "Ragebot", "Main", "Double Tap", "Immediate Teleport" }),
	dt_fakelag = bs_air_exploit.find_handle({ "Aimbot", "Ragebot", "Main", "Double Tap", "Fake Lag Limit" }),
	fakelag_limit = bs_config.antiaim.fake_lag.limit,
	fakelag_var = bs_config.antiaim.fake_lag.variability,
	yaw_offset = bs_config.antiaim.angles.yaw_add,
	body_yaw = bs_config.antiaim.angles.body_yaw,
	hide_shots = bs_config.rage.main.hide_shots,
	fake_duck = bs_config.antiaim.misc.fake_duck,
	mod_offset = bs_config.antiaim.angles.modifier_offset,
}

function bs_air_exploit.ovr(handle, value)
	if not handle then
		return
	end

	pcall(function()
		if value == nil then
			handle:override()
		else
			handle:override(value)
		end
	end)
end

function bs_air_exploit.reset()
	bs_air_exploit.ovr(bs_air_exploit.h.dt_lag, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_immediate, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_fakelag, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.fakelag_limit, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.fakelag_var, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.yaw_offset, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.body_yaw, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.hide_shots, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.fake_duck, nil)
	bs_air_exploit.ovr(bs_air_exploit.h.mod_offset, nil)

	if bs_air_exploit.orig_ticks then
		pcall(function()
			bs_air_exploit.cmd_ticks:int(bs_air_exploit.orig_ticks)
		end)
	end
end

function bs_air_exploit.forward_track(cmd)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_lag, "On Peek")
	bs_air_exploit.ovr(bs_air_exploit.h.fakelag_limit, 1)
	bs_air_exploit.ovr(bs_air_exploit.h.yaw_offset, 0)
	bs_air_exploit.ovr(bs_air_exploit.h.dt, true)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_immediate, false)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_fakelag, 1)
	bs_air_exploit.ovr(bs_air_exploit.h.fakelag_var, 0)
	bs_air_exploit.ovr(bs_air_exploit.h.body_yaw, false)
	bs_air_exploit.ovr(bs_air_exploit.h.hide_shots, false)

	if not entity.get_local_player() then
		return
	end

	pcall(function()
		bs_air_exploit.cmd_ticks:int(19)
	end)

	if not cmd.in_jump then
		return
	end

	if globals.tickcount % 4 == 0 then
		pcall(function()
			rage.exploit:force_teleport()
		end)
		pcall(function()
			rage.exploit:allow_charge(false)
		end)
		cmd.force_defensive = false
	else
		pcall(function()
			rage.exploit:allow_charge(true)
		end)
		pcall(function()
			rage.exploit:force_charge()
		end)
		cmd.force_defensive = true
	end

	if globals.tickcount % 10 == 0 then
		pcall(function()
			rage.exploit:force_teleport()
		end)
		pcall(function()
			rage.exploit:allow_charge(false)
		end)
		cmd.force_defensive = false
	else
		pcall(function()
			rage.exploit:allow_charge(true)
		end)
		pcall(function()
			rage.exploit:force_charge()
		end)
		cmd.force_defensive = true
	end
end

function bs_air_exploit.back_track(cmd)
	bs_air_exploit.ovr(bs_air_exploit.h.mod_offset, 0)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_lag, "On Peek")
	bs_air_exploit.ovr(bs_air_exploit.h.fakelag_limit, 17)
	bs_air_exploit.ovr(bs_air_exploit.h.yaw_offset, 0)
	bs_air_exploit.ovr(bs_air_exploit.h.dt, true)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_immediate, false)
	bs_air_exploit.ovr(bs_air_exploit.h.dt_fakelag, 1)
	bs_air_exploit.ovr(bs_air_exploit.h.fakelag_var, 0)
	bs_air_exploit.ovr(bs_air_exploit.h.body_yaw, false)
	bs_air_exploit.ovr(bs_air_exploit.h.hide_shots, false)

	if not entity.get_local_player() then
		return
	end

	if not cmd.in_jump then
		bs_air_exploit.ovr(bs_air_exploit.h.fake_duck, nil)
		bs_air_exploit.ovr(bs_air_exploit.h.body_yaw, nil)
		return
	end

	if globals.tickcount % 2 == 1 then
		pcall(function()
			bs_air_exploit.cmd_ticks:int(16)
		end)
		bs_air_exploit.ovr(bs_air_exploit.h.fake_duck, true)
	else
		pcall(function()
			bs_air_exploit.cmd_ticks:int(19)
		end)
		bs_air_exploit.ovr(bs_air_exploit.h.fake_duck, false)
	end
end

events.createmove(function(arg_102_0)
	local var_102_0 = bs_v597.air_exploit

	if not var_102_0 or not var_102_0:get() then
		if bs_air_exploit.active then
			bs_air_exploit.reset()
			bs_air_exploit.active = false
		end

		return
	end

	bs_air_exploit.active = true

	if bs_v597.air_mode and bs_v597.air_mode:get() == "back track" then
		bs_air_exploit.back_track(arg_102_0)
	else
		bs_air_exploit.forward_track(arg_102_0)
	end
end)

events.shutdown(function()
	bs_air_exploit.reset()
end)

-- ===== CONSOLE MODULATION =====
-- Ported from open_source_luas/script_D06v7wLz.bin_oracle.lua ("Console
-- Modulation"). Tints the console/HUD materials while the console is open and
-- restores them when it closes. All API calls are pcall-guarded so a missing
-- `materials`/`utils.get_vfunc` global degrades to a no-op instead of erroring.
bs_console_mod = {
	active = false,
	console_open = nil,
}

pcall(function()
	bs_console_mod.console_open = utils.get_vfunc("engine.dll", "VEngineClient014", 11, "bool(__thiscall*)(void*)")
end)

function bs_console_mod.tint(col)
	if type(materials) ~= "table" and type(materials) ~= "userdata" then
		return
	end

	local alpha = (col and col.a and col.a / 255) or 1

	pcall(function()
		for _, mat in pairs(materials.get_materials("vgui/hud/800") or {}) do
			mat:color_modulate(col)
			mat:alpha_modulate(alpha)
		end
	end)

	pcall(function()
		for _, mat in pairs(materials.get_materials("vgui_white") or {}) do
			mat:color_modulate(col)
			mat:alpha_modulate(alpha)
		end
	end)
end

function bs_console_mod.restore()
	bs_console_mod.tint(color(255, 255, 255, 255))
end

function bs_console_mod.is_console_open()
	if not bs_console_mod.console_open then
		return false
	end

	local ok, open = pcall(bs_console_mod.console_open)

	if ok then
		return open == true
	end

	return false
end

events.render(function()
	local var_590_0 = bs_v684.console_mod

	if not var_590_0 or not var_590_0:get() then
		if bs_console_mod.active then
			bs_console_mod.restore()
			bs_console_mod.active = false
		end

		return
	end

	if bs_console_mod.is_console_open() then
		if not bs_console_mod.active then
			local var_590_1 = bs_v684.console_mod_col and bs_v684.console_mod_col:get() or color(47, 47, 60, 222)

			bs_console_mod.tint(var_590_1)
			bs_console_mod.active = true
		end
	elseif bs_console_mod.active then
		bs_console_mod.restore()
		bs_console_mod.active = false
	end
end)

events.shutdown(function()
	bs_console_mod.restore()
end)

bs_pui.setup(bs_menu)

bs_v183 = "bluesense_builder_v2"
bs_v206 = "bluesense_pui_v2"
bs_v225 = "bluesense_positions_v2"
bs_v245 = "bluesense_theme_v2"
bs_v263 = "bluesense_ind_state_v1"
bs_v277 = "bluesense_defensive_v1"
bs_v292 = false
bs_v305 = 0
bs_v318 = true
bs_v331 = {
	"allow_state",
	"yaw_mode",
	"yaw_left",
	"yaw_right",
	"async_yaw",
	"async_yaw_left",
	"async_yaw_right",
	"gravity_yaw_left",
	"gravity_yaw_right",
	"gravity_step_1",
	"gravity_step_2",
	"gravity_step_3",
	"gravity_step_4",
	"gravity_step_5",
	"gravity_step_6",
	"gravity_step_7",
	"gravity_step_8",
	"yaw_add",
	"yaw_jitter",
	"lr_rand_pct",
	"delay",
	"delay_mode",
	"delay_ticks",
	"delay_random_min",
	"delay_random_max",
	"delay_seq_count",
	"delay_seq_s1",
	"delay_seq_s2",
	"delay_seq_s3",
	"delay_seq_s4",
	"delay_seq_s5",
	"delay_seq_s6",
	"delay_seq_s7",
	"delay_seq_s8",
	"jitter_base",
	"jitter_range",
	"jitter_speed",
	"jitter_style",
	"jitter_phase",
	"jitter_asymmetry",
	"chaotic_range",
	"chaotic_seed_rate",
	"chaotic_smooth",
	"yaw_base",
	"modifier",
	"randomize",
	"modifier_mode",
	"min",
	"max",
	"chaos_range",
	"modifier_weight_center",
	"modifier_weight_spread",
	"modifier_pulse_a",
	"modifier_pulse_b",
	"modifier_pulse_rate",
	"modifier_custom_sliders",
	"modifier_sliders_1",
	"modifier_sliders_2",
	"modifier_sliders_3",
	"modifier_sliders_4",
	"modifier_sliders_5",
	"modifier_sliders_6",
	"modifier_offset",
	"skitter_deg",
	"dual_left_off",
	"dual_right_off",
	"dual_distribution",
	"dual_rate",
	"dual_rate_b",
	"body_yaw",
	"body_yaw_mode",
	"body_yaw_delay_mode",
	"body_yaw_delay",
	"body_yaw_delay_random_min",
	"body_yaw_delay_random_max",
	"body_yaw_delay_seq_count",
	"body_yaw_delay_seq_s1",
	"body_yaw_delay_seq_s2",
	"body_yaw_delay_seq_s3",
	"body_yaw_delay_seq_s4",
	"body_yaw_delay_seq_s5",
	"body_yaw_delay_seq_s6",
	"body_yaw_delay_seq_s7",
	"body_yaw_delay_seq_s8",
	"body_yaw_delay_seq_s9",
	"body_yaw_delay_seq_s10",
	"fake_limit",
	"freestand_peek",
	"left_limit",
	"right_limit",
	"choke",
	"random_choke",
	"choke_slider",
	"choke_method",
	"choke_from",
	"choke_to",
	"choke_sliders",
	"choke1_1",
	"choke1_2",
	"choke1_3",
	"choke1_4",
	"choke1_5",
	"choke1_6",
	"anti_bruteforce",
	"abf_reset_timer",
	"abf_trigger",
	"abf_notify",
	"abf_phase_sel"
}

function bs_v344()
	local var_588_0 = bs_menu.antiaim.angles.builder

	if not var_588_0 then
		return nil
	end

	local var_588_1 = {}

	for iter_588_0, iter_588_1 in pairs(var_588_0) do
		local var_588_2 = {}

		for iter_588_2, iter_588_3 in ipairs(bs_v331) do
			local var_588_3 = iter_588_1[iter_588_3]

			if var_588_3 then
				pcall(function()
					var_588_2[iter_588_3] = var_588_3:get()
				end)
			end
		end

		if iter_588_1.abf_phases then
			local var_588_4 = {}

			for iter_588_4 = 1, 10 do
				local var_588_5 = iter_588_1.abf_phases[iter_588_4]

				if var_588_5 then
					local var_588_6 = {}

					pcall(function()
						var_588_6.rand_min = var_588_5.rand_min:get()
					end)
					pcall(function()
						var_588_6.rand_max = var_588_5.rand_max:get()
					end)

					var_588_4[iter_588_4] = var_588_6
				end
			end

			var_588_2.__abf_phases = var_588_4

			pcall(function()
				var_588_2.__abf_phase_n = iter_588_1.abf_phase_n
			end)
		end

		var_588_1[iter_588_0] = var_588_2
	end

	return var_588_1
end

function bs_v357(arg_593_0)
	if not arg_593_0 then
		return
	end

	local var_593_0 = bs_menu.antiaim.angles.builder

	if not var_593_0 then
		return
	end

	for iter_593_0, iter_593_1 in pairs(arg_593_0) do
		local var_593_1 = var_593_0[iter_593_0]

		if var_593_1 then
			for iter_593_2, iter_593_3 in ipairs(bs_v331) do
				local var_593_2 = var_593_1[iter_593_3]
				local var_593_3 = iter_593_1[iter_593_3]

				if var_593_2 and var_593_3 ~= nil then
					pcall(function()
						var_593_2:set(var_593_3)
					end)
				end
			end

			if iter_593_1.__abf_phase_n and var_593_1.abf_phase_n ~= nil then
				pcall(function()
					var_593_1.abf_phase_n = iter_593_1.__abf_phase_n
				end)
				pcall(function()
					if var_593_1.abf_phase_sel then
						local var_596_0 = {}

						for iter_596_0 = 1, var_593_1.abf_phase_n do
							var_596_0[iter_596_0] = tostring(iter_596_0)
						end

						if #var_596_0 > 0 then
							var_593_1.abf_phase_sel:update(var_596_0)
						end
					end
				end)
			end

			if iter_593_1.__abf_phases and var_593_1.abf_phases then
				for iter_593_4 = 1, 10 do
					local var_593_4 = var_593_1.abf_phases[iter_593_4]
					local var_593_5 = iter_593_1.__abf_phases[iter_593_4]

					if var_593_4 and var_593_5 then
						if var_593_5.rand_min ~= nil then
							pcall(function()
								var_593_4.rand_min:set(var_593_5.rand_min)
							end)
						end

						if var_593_5.rand_max ~= nil then
							pcall(function()
								var_593_4.rand_max:set(var_593_5.rand_max)
							end)
						end
					end
				end
			end
		end
	end
end

bs_v368 = {
	"fe",
	"fe_alt",
	"fe_peek",
	"fe_snap_delay",
	"enable",
	"pitch_mode",
	"pitch",
	"dyn_pitch_min",
	"dyn_pitch_max",
	"dyn_pitch_spd",
	"dyn_pitch_mode",
	"dyn_pitch_rand",
	"osc_pitch_a",
	"osc_pitch_b",
	"osc_pitch_rate",
	"osc_pitch_rand",
	"yaw_mode",
	"yaw",
	"yaw_lr_left",
	"yaw_lr_right",
	"yaw_lr_dt",
	"yaw_lr_rand",
	"def_flip_adaptive",
	"def_flip_adp_var",
	"yaw_spin_from",
	"yaw_spin_to",
	"yaw_spin_spd",
	"yaw_spin_rand",
	"dyn_yaw_min",
	"dyn_yaw_max",
	"dyn_yaw_spd",
	"dyn_yaw_mode",
	"dyn_yaw_rand",
	"def_jitter_base",
	"def_jitter_range",
	"def_jitter_speed",
	"def_jitter_style",
	"def_jitter_phase",
	"sweep_from",
	"sweep_to",
	"sweep_rate",
	"sweep_hold",
	"sweep_rand",
	"activation_mode",
	"def_abf",
	"def_abf_mode",
	"def_abf_trigger",
	"def_abf_reset",
	"def_abf_notify"
}

function bs_v378()
	local var_599_0 = bs_menu.antiaim.defensive

	if not var_599_0 or not var_599_0.settings then
		return nil
	end

	local var_599_1 = {}

	for iter_599_0, iter_599_1 in pairs(var_599_0.settings) do
		local var_599_2 = {}

		for iter_599_2, iter_599_3 in ipairs(bs_v368) do
			local var_599_3 = iter_599_1[iter_599_3]

			if var_599_3 then
				pcall(function()
					var_599_2[iter_599_3] = var_599_3:get()
				end)
			end
		end

		var_599_1[iter_599_0] = var_599_2
	end

	return var_599_1
end

function bs_v387(arg_601_0)
	if not arg_601_0 then
		return
	end

	local var_601_0 = bs_menu.antiaim.defensive

	if not var_601_0 or not var_601_0.settings then
		return
	end

	for iter_601_0, iter_601_1 in pairs(arg_601_0) do
		local var_601_1 = var_601_0.settings[iter_601_0]

		if var_601_1 then
			for iter_601_2, iter_601_3 in ipairs(bs_v368) do
				local var_601_2 = var_601_1[iter_601_3]
				local var_601_3 = iter_601_1[iter_601_3]

				if var_601_2 and var_601_3 ~= nil then
					pcall(function()
						var_601_2:set(var_601_3)
					end)
				end
			end
		end
	end
end

bs_get_builder = bs_v344
bs_v500 = bs_v357
bs_get_defensive = bs_v378
bs_v509 = bs_v387
bs_v395 = {
	"double tap",
	"hide shots",
	"freestanding",
	"fake duck",
	"min damage",
	"dormant aimbot",
	"lc",
	"ping"
}

function bs_v404()
	local var_603_0 = bs_ui_elements
	local var_603_1 = var_603_0._select

	if not var_603_1 then
		return nil
	end

	local var_603_2 = {}

	for iter_603_0, iter_603_1 in ipairs(bs_v395) do
		local var_603_3, var_603_4 = pcall(function()
			return var_603_1:get(iter_603_1)
		end)

		if var_603_3 and var_603_4 then
			var_603_2[#var_603_2 + 1] = iter_603_1
		end
	end

	local var_603_5 = {
		selected = var_603_2
	}

	pcall(function()
		var_603_5.enabled = var_603_0._label:get()
	end)

	local function var_603_6(arg_606_0, arg_606_1)
		if arg_606_1 and arg_606_1.get then
			local var_606_0, var_606_1 = pcall(function()
				return arg_606_1:get()
			end)

			if var_606_0 and var_606_1 then
				var_603_5[arg_606_0] = {
					var_606_1.r,
					var_606_1.g,
					var_606_1.b,
					var_606_1.a
				}
			end
		end
	end

	var_603_6("bg", var_603_0.col_bg)
	var_603_6("col_dt_on", var_603_0.col_dt_on)
	var_603_6("col_dt_off", var_603_0.col_dt_off)
	var_603_6("col_hs_on", var_603_0.col_hs_on)
	var_603_6("col_fs_on", var_603_0.col_fs_on)
	var_603_6("col_fd_on", var_603_0.col_fd_on)
	var_603_6("col_da_on", var_603_0.col_da_on)
	var_603_6("col_dmg_on", var_603_0.col_dmg_on)
	var_603_6("col_lc_on", var_603_0.col_lc_on)
	var_603_6("col_lc_bad", var_603_0.col_lc_bad)
	var_603_6("col_ping_on", var_603_0.col_ping_on)
	pcall(function()
		var_603_5.blur = var_603_0.blur:get()
	end)
	pcall(function()
		var_603_5.font = var_603_0.font:get()
	end)

	return var_603_5
end

function bs_v412(arg_610_0)
	if not arg_610_0 then
		return
	end

	local var_610_0 = bs_ui_elements
	local var_610_1 = var_610_0._select

	if arg_610_0.selected and var_610_1 then
		pcall(function()
			var_610_1:set(arg_610_0.selected)
		end)
	end

	if arg_610_0.enabled ~= nil then
		pcall(function()
			var_610_0._label:set(arg_610_0.enabled)
		end)
	end

	local function var_610_2(arg_613_0, arg_613_1)
		if arg_610_0[arg_613_0] and arg_613_1 and arg_613_1.set then
			local var_613_0 = arg_610_0[arg_613_0]

			pcall(function()
				arg_613_1:set(color(var_613_0[1], var_613_0[2], var_613_0[3], var_613_0[4]))
			end)
		end
	end

	var_610_2("bg", var_610_0.col_bg)
	var_610_2("col_dt_on", var_610_0.col_dt_on)
	var_610_2("col_dt_off", var_610_0.col_dt_off)
	var_610_2("col_hs_on", var_610_0.col_hs_on)
	var_610_2("col_fs_on", var_610_0.col_fs_on)
	var_610_2("col_fd_on", var_610_0.col_fd_on)
	var_610_2("col_da_on", var_610_0.col_da_on)
	var_610_2("col_dmg_on", var_610_0.col_dmg_on)
	var_610_2("col_lc_on", var_610_0.col_lc_on)
	var_610_2("col_lc_bad", var_610_0.col_lc_bad)
	var_610_2("col_ping_on", var_610_0.col_ping_on)

	if arg_610_0.blur ~= nil then
		pcall(function()
			var_610_0.blur:set(arg_610_0.blur)
		end)
	end

	if arg_610_0.font ~= nil then
		pcall(function()
			var_610_0.font:set(arg_610_0.font)
		end)
	end
end

function bs_v419()
	if bs_v318 then
		return
	end

	local var_617_0 = bs_v344()

	if var_617_0 then
		db[bs_v183] = var_617_0
	end

	local var_617_1 = bs_v378()

	if var_617_1 then
		db[bs_v277] = var_617_1
	end

	local var_617_2, var_617_3 = pcall(function()
		return bs_pui.save()
	end)

	if var_617_2 and var_617_3 then
		db[bs_v206] = var_617_3
	end

	if bs_v514.save_positions_full then
		local var_617_4, var_617_5 = pcall(bs_v514.save_positions_full)

		if var_617_4 and var_617_5 then
			db[bs_v225] = var_617_5
		end
	end

	pcall(function()
		local var_619_0 = bs_v479:get()

		db[bs_v245] = {
			r = var_619_0.r,
			g = var_619_0.g,
			b = var_619_0.b,
			a = var_619_0.a,
			share_logo = bs_v480:get()
		}
	end)

	local var_617_6 = bs_v404()

	if var_617_6 then
		db[bs_v263] = var_617_6
	end
end

utils.execute_after(0.5, function()
	local var_620_0 = db[bs_v206]

	if var_620_0 then
		pcall(function()
			bs_pui.load(var_620_0)
		end)
	end

	local var_620_1 = db[bs_v225]

	if var_620_1 and bs_v514.load_positions_full then
		pcall(bs_v514.load_positions_full, var_620_1)
	end

	local var_620_2 = db[bs_v245]

	if var_620_2 then
		pcall(function()
			bs_v479:set(color(var_620_2.r, var_620_2.g, var_620_2.b, var_620_2.a or 255))
			bs_v480:set(var_620_2.share_logo == true)
		end)
	end

	local var_620_3 = db[bs_v183]

	if var_620_3 then
		utils.execute_after(0.05, function()
			bs_v357(var_620_3)

			bs_v292 = true
			bs_v305 = globals.realtime
			bs_v318 = false
		end)
	else
		bs_v292 = true
		bs_v305 = globals.realtime
		bs_v318 = false
	end

	local var_620_4 = db[bs_v277]

	if var_620_4 then
		utils.execute_after(0.05, function()
			bs_v387(var_620_4)
		end)
	end

	local var_620_5 = db[bs_v263]

	if var_620_5 then
		utils.execute_after(0.2, function()
			bs_v412(var_620_5)
		end)
	end
end)
events.render(function()
	if bs_v318 then
		return
	end

	local var_626_0 = globals.realtime

	if var_626_0 - bs_v305 >= 2 then
		bs_v305 = var_626_0

		bs_v419()
	end
end)
events.shutdown(bs_v419)
bs_v482()

bs_v178 = "https://cdn.jsdelivr.net/gh/yirahvh-spec/bluesense@main/bluesensen.png"
bs_v202 = {
	code_mul = 97,
	latest_rollcall = 0,
	users = {}
}

function bs_v224()
	if not globals.is_in_game then
		return
	end

	local var_627_0 = #cvar.name:string()
	local var_627_1 = utils.random_int(256, 4095)

	events.voice_message:call(function(arg_628_0)
		arg_628_0:write_bits(0, 4)
		arg_628_0:write_bits(var_627_0, 8)
		arg_628_0:write_bits(1, 4)
		arg_628_0:write_bits(var_627_1 * (bs_v202.code_mul - var_627_0 - 1), 20)
		arg_628_0:write_bits(var_627_1, 12)
	end)
end

function bs_v244(arg_629_0, arg_629_1, arg_629_2)
	if not arg_629_0 or arg_629_0:is_bot() then
		return
	end

	local var_629_0 = arg_629_0:get_player_info().steamid

	if bs_v480 and bs_v480:get() and arg_629_1 and arg_629_1 == 1 then
		if not bs_v202.users[var_629_0] then
			pcall(function()
				arg_629_0:set_icon(bs_v178)
			end)

			bs_v202.users[var_629_0] = true
		end
	elseif bs_v202.users[var_629_0] and not arg_629_2 then
		pcall(function()
			arg_629_0:set_icon()
		end)

		bs_v202.users[var_629_0] = nil
	end
end

function bs_v262(arg_632_0)
	if arg_632_0 or math.abs(globals.tickcount - bs_v202.latest_rollcall) > 256 then
		bs_v224()

		local var_632_0 = entity.get_local_player()

		if var_632_0 then
			if arg_632_0 then
				local var_632_1 = var_632_0:get_player_info().steamid

				bs_v202.users[var_632_1] = nil
			end

			bs_v244(var_632_0, 1, true)
		end

		bs_v202.latest_rollcall = globals.tickcount
	end
end

function bs_voice_handler(arg_633_0)
	if arg_633_0.entity and arg_633_0.xuid == 0 then
		local var_633_0 = #arg_633_0.entity:get_name()
		local var_633_1 = arg_633_0.buffer:read_bits(4)
		local var_633_2 = arg_633_0.buffer:read_bits(8)
		local var_633_3 = arg_633_0.buffer:read_bits(4)
		local var_633_4 = arg_633_0.buffer:read_bits(20)
		local var_633_5 = arg_633_0.buffer:read_bits(12)
		local var_633_6 = bs_v202.code_mul - var_633_0 - 1

		if var_633_1 == 0 and var_633_2 == var_633_0 and var_633_3 == 1 and var_633_6 ~= 0 and var_633_5 ~= 0 and var_633_4 % var_633_6 == 0 and var_633_4 % var_633_5 == 0 then
			bs_v244(arg_633_0.entity, 1)
		end
	end

	bs_v262()
end

function bs_v291()
	bs_iter_players(false, true, function(arg_635_0)
		bs_v244(arg_635_0)
	end)

	bs_v202.users = {}
end

bs_v224()

if bs_v480 then
	bs_v480:set_callback(function(arg_636_0)
		events.voice_message(bs_voice_handler, arg_636_0:get())

		if arg_636_0:get() then
			bs_v262(true)

			local var_636_0 = entity.get_local_player()

			if var_636_0 then
				bs_v244(var_636_0, 1, true)
			end
		else
			bs_v291()
		end
	end, true)
end

events.player_spawned(function()
	bs_v262(true)
end)
events.player_death(bs_v262)
events.round_start(function()
	bs_v291()
	bs_v262(true)
end)
events.round_prestart(bs_v291)
events.level_change(function()
	bs_v291()
	bs_v262(true)
end)
events.shutdown(bs_v291)

bs_v167 = 1
bs_v191 = false
bs_v213 = bs_config.antiaim.misc.fake_duck
bs_v233 = bs_config.rage.main.double_tap
bs_v253 = bs_config.rage.main.hide_shots

function bs_v271()
	pcall(function()
		bs_v213:override()
	end)
end

bs_v285 = {}
bs_v300 = 1
bs_v314 = 0
bs_v327 = 0
bs_v340 = 80
bs_v353 = 1.6
bs_v366 = 0.025
bs_v376 = 0
bs_v386 = nil
bs_v394 = nil
bs_v403 = 0
bs_v411 = 0
bs_v418 = 0
bs_v425 = 5
bs_v430 = false
bs_v434 = -1000
bs_v438 = 0.45
bs_v442 = false

function bs_v446()
	local var_642_0 = bs_menu.antiaim.general.air_exploit

	if not var_642_0 then
		return false
	end

	if not var_642_0.switch:get() then
		return false
	end

	local var_642_1, var_642_2 = pcall(function()
		return var_642_0.visualization:get()
	end)

	return var_642_1 and var_642_2
end

function bs_v450()
	local var_644_0 = bs_menu.antiaim.general.air_exploit
	local var_644_1, var_644_2 = pcall(function()
		return var_644_0.color:get()
	end)

	if var_644_1 and var_644_2 then
		return var_644_2
	end

	return color(150, 195, 255, 255)
end

function bs_v454(arg_646_0)
	return math.max(0, math.min(255, math.floor(arg_646_0 + 0.5)))
end

function bs_v457(arg_647_0, arg_647_1, arg_647_2, arg_647_3, arg_647_4, arg_647_5, arg_647_6, arg_647_7)
	if arg_647_7 < 3 then
		return
	end

	bs_v2062 = arg_647_2 - arg_647_0
	bs_v2063 = arg_647_3 - arg_647_1
	bs_v2033 = math.sqrt(bs_v2062 * bs_v2062 + bs_v2063 * bs_v2063)

	if bs_v2033 < 0.5 then
		return
	end

	bs_v2034 = 1 / bs_v2033
	bs_v2035 = -bs_v2063 * bs_v2034
	bs_v2036 = bs_v2062 * bs_v2034
	bs_v2037 = math.floor(arg_647_0 + 0.5)
	bs_v2038 = math.floor(arg_647_1 + 0.5)
	bs_v2039 = math.floor(arg_647_2 + 0.5)
	bs_v2040 = math.floor(arg_647_3 + 0.5)
	bs_v2041 = bs_v454(arg_647_7 * 0.06)

	if bs_v2041 > 1 then
		bs_v2043 = color(arg_647_4, arg_647_5, arg_647_6, bs_v2041)
		bs_v2046 = math.floor(bs_v2035 * 8 + 0.5)
		bs_v2050 = math.floor(bs_v2036 * 8 + 0.5)
		bs_v2055 = math.floor(bs_v2035 * 6 + 0.5)
		bs_v2059 = math.floor(bs_v2036 * 6 + 0.5)

		render.line(vector(bs_v2037 - bs_v2046, bs_v2038 - bs_v2050), vector(bs_v2039 - bs_v2046, bs_v2040 - bs_v2050), bs_v2043)
		render.line(vector(bs_v2037 - bs_v2055, bs_v2038 - bs_v2059), vector(bs_v2039 - bs_v2055, bs_v2040 - bs_v2059), bs_v2043)
		render.line(vector(bs_v2037 + bs_v2055, bs_v2038 + bs_v2059), vector(bs_v2039 + bs_v2055, bs_v2040 + bs_v2059), bs_v2043)
		render.line(vector(bs_v2037 + bs_v2046, bs_v2038 + bs_v2050), vector(bs_v2039 + bs_v2046, bs_v2040 + bs_v2050), bs_v2043)
	end

	bs_v2042 = bs_v454(arg_647_7 * 0.13)

	if bs_v2042 > 2 then
		bs_v2045 = color(arg_647_4, arg_647_5, arg_647_6, bs_v2042)
		bs_v2049 = math.floor(bs_v2035 * 4 + 0.5)
		bs_v2054 = math.floor(bs_v2036 * 4 + 0.5)
		bs_v2058 = math.floor(bs_v2035 * 3 + 0.5)
		bs_v2061 = math.floor(bs_v2036 * 3 + 0.5)

		render.line(vector(bs_v2037 - bs_v2049, bs_v2038 - bs_v2054), vector(bs_v2039 - bs_v2049, bs_v2040 - bs_v2054), bs_v2045)
		render.line(vector(bs_v2037 - bs_v2058, bs_v2038 - bs_v2061), vector(bs_v2039 - bs_v2058, bs_v2040 - bs_v2061), bs_v2045)
		render.line(vector(bs_v2037 + bs_v2058, bs_v2038 + bs_v2061), vector(bs_v2039 + bs_v2058, bs_v2040 + bs_v2061), bs_v2045)
		render.line(vector(bs_v2037 + bs_v2049, bs_v2038 + bs_v2054), vector(bs_v2039 + bs_v2049, bs_v2040 + bs_v2054), bs_v2045)
	end

	bs_v2044 = bs_v454(arg_647_7 * 0.28)

	if bs_v2044 > 3 then
		bs_v2048 = color(arg_647_4, arg_647_5, arg_647_6, bs_v2044)
		bs_v2053 = math.floor(bs_v2035 * 2 + 0.5)
		bs_v2057 = math.floor(bs_v2036 * 2 + 0.5)

		render.line(vector(bs_v2037 - bs_v2053, bs_v2038 - bs_v2057), vector(bs_v2039 - bs_v2053, bs_v2040 - bs_v2057), bs_v2048)
		render.line(vector(bs_v2037 + bs_v2053, bs_v2038 + bs_v2057), vector(bs_v2039 + bs_v2053, bs_v2040 + bs_v2057), bs_v2048)
	end

	bs_v2047 = bs_v454(arg_647_7 * 0.55)

	if bs_v2047 > 4 then
		bs_v2052 = color(bs_v454(arg_647_4 + 40), bs_v454(arg_647_5 + 40), bs_v454(arg_647_6 + 40), bs_v2047)
		bs_v2056 = math.floor(bs_v2035 + 0.5)
		bs_v2060 = math.floor(bs_v2036 + 0.5)

		render.line(vector(bs_v2037 - bs_v2056, bs_v2038 - bs_v2060), vector(bs_v2039 - bs_v2056, bs_v2040 - bs_v2060), bs_v2052)
		render.line(vector(bs_v2037 + bs_v2056, bs_v2038 + bs_v2060), vector(bs_v2039 + bs_v2056, bs_v2040 + bs_v2060), bs_v2052)
	end

	bs_v2051 = color(bs_v454(arg_647_4 + 90), bs_v454(arg_647_5 + 90), bs_v454(arg_647_6 + 90), bs_v454(arg_647_7 * 0.97))

	render.line(vector(bs_v2037, bs_v2038), vector(bs_v2039, bs_v2040), bs_v2051)
end

function bs_v459(arg_648_0, arg_648_1, arg_648_2, arg_648_3, arg_648_4, arg_648_5)
	if arg_648_5 < 8 then
		return
	end

	local var_648_0 = math.floor(arg_648_0 + 0.5)
	local var_648_1 = math.floor(arg_648_1 + 0.5)

	render.circle_outline(vector(var_648_0, var_648_1), color(arg_648_2, arg_648_3, arg_648_4, bs_v454(arg_648_5 * 0.1)), 9, 0, 360, 3)
	render.circle_outline(vector(var_648_0, var_648_1), color(arg_648_2, arg_648_3, arg_648_4, bs_v454(arg_648_5 * 0.18)), 7, 0, 360, 2)
	render.circle_outline(vector(var_648_0, var_648_1), color(bs_v454(arg_648_2 + 40), bs_v454(arg_648_3 + 40), bs_v454(arg_648_4 + 40), bs_v454(arg_648_5 * 0.35)), 5, 0, 360, 2)
	render.circle_outline(vector(var_648_0, var_648_1), color(bs_v454(arg_648_2 + 70), bs_v454(arg_648_3 + 70), bs_v454(arg_648_4 + 70), bs_v454(arg_648_5 * 0.65)), 3, 0, 360, 1)
	render.circle(vector(var_648_0, var_648_1), color(bs_v454(arg_648_2 + 90), bs_v454(arg_648_3 + 90), bs_v454(arg_648_4 + 90), bs_v454(arg_648_5 * 0.95)), 2, 0, 360)
end

function bs_v461(arg_649_0, arg_649_1, arg_649_2, arg_649_3)
	if bs_v394 then
		local var_649_0 = arg_649_1 - bs_v394[1]
		local var_649_1 = arg_649_2 - bs_v394[2]
		local var_649_2 = arg_649_3 - bs_v394[3]

		if var_649_0 * var_649_0 + var_649_1 * var_649_1 + var_649_2 * var_649_2 > 16384 then
			bs_v285 = {}
			bs_v300 = 1
			bs_v314 = 0
			bs_v327 = 0
			bs_v386 = nil
		end
	end

	bs_v394 = {
		arg_649_1,
		arg_649_2,
		arg_649_3
	}

	if bs_v386 then
		local var_649_3 = arg_649_1 - bs_v386[1]
		local var_649_4 = arg_649_2 - bs_v386[2]
		local var_649_5 = arg_649_3 - bs_v386[3]

		if var_649_3 * var_649_3 + var_649_4 * var_649_4 + var_649_5 * var_649_5 < 1 then
			return
		end
	end

	bs_v386 = {
		arg_649_1,
		arg_649_2,
		arg_649_3
	}
	bs_v314 = bs_v314 % bs_v340 + 1
	bs_v285[bs_v314] = {
		x = arg_649_1,
		y = arg_649_2,
		z = arg_649_3 + 18,
		born = arg_649_0
	}

	if bs_v327 < bs_v340 then
		bs_v327 = bs_v327 + 1
	else
		bs_v300 = bs_v300 % bs_v340 + 1
	end
end

events.createmove(function(arg_650_0)
	local var_650_0 = bs_menu.antiaim.general.air_exploit

	if not var_650_0 then
		return
	end

	if not var_650_0.switch:get() then
		if not bs_v191 then
			bs_v271()

			bs_v191 = true
		end

		return
	end

	local var_650_1 = entity.get_local_player()

	if not var_650_1 or not var_650_1:is_alive() then
		if not bs_v191 then
			bs_v271()

			bs_v191 = true
		end

		return
	end

	local var_650_2 = bit.band(var_650_1.m_fFlags or 0, 1) == 1
	local var_650_3, var_650_4 = pcall(function()
		return bs_v233:get()
	end)
	local var_650_5, var_650_6 = pcall(function()
		return bs_v253:get()
	end)
	local var_650_7 = var_650_3 and var_650_4 or var_650_5 and var_650_6

	if var_650_2 or not var_650_7 then
		bs_v271()

		bs_v167 = 1
		bs_v191 = false

		if bs_v430 then
			bs_v434 = globals.realtime
		end

		bs_v430 = false

		local var_650_8 = globals.realtime

		if bs_v446() and var_650_8 - bs_v434 < bs_v438 and var_650_8 >= bs_v376 then
			bs_v376 = var_650_8 + bs_v366

			local var_650_9, var_650_10 = pcall(function()
				return var_650_1:get_origin()
			end)

			if var_650_9 and var_650_10 then
				bs_v461(var_650_8, var_650_10.x, var_650_10.y, var_650_10.z)
			end
		end

		if globals.realtime - bs_v434 >= bs_v438 then
			bs_v386 = nil
			bs_v394 = nil
		end

		return
	end

	bs_v434 = -1000
	bs_v430 = true

	if bs_v446() then
		local var_650_11 = globals.realtime

		if var_650_11 >= bs_v376 then
			bs_v376 = var_650_11 + bs_v366

			local var_650_12, var_650_13 = pcall(function()
				return var_650_1:get_origin()
			end)

			if var_650_12 and var_650_13 then
				bs_v461(var_650_11, var_650_13.x, var_650_13.y, var_650_13.z)
			end
		end
	end

	if globals.tickcount % 2 == 1 then
		bs_v167 = bs_v167 + 1
	end

	if bs_v167 > 2 then
		pcall(function()
			bs_v213:override(true)
		end)

		bs_v167 = 1
	else
		pcall(function()
			bs_v213:override(false)
		end)
	end

	bs_v191 = false
end)
events.render(function()
	bs_v2064 = bs_v446()
	bs_v411 = bs_v2064 and (bs_v430 or bs_v327 > 0) and 1 or 0
	bs_v2065 = globals.realtime
	bs_v2087 = math.min(bs_v2065 - bs_v418, 0.05)
	bs_v418 = bs_v2065

	if bs_v403 < bs_v411 then
		bs_v403 = math.min(bs_v411, bs_v403 + bs_v425 * bs_v2087)
	elseif bs_v403 > bs_v411 then
		bs_v403 = math.max(bs_v411, bs_v403 - bs_v425 * bs_v2087)
	end

	if bs_v403 < 0.004 then
		if not bs_v2064 then
			bs_v285 = {}
			bs_v300 = 1
			bs_v314 = 0
			bs_v327 = 0
		end

		return
	end

	bs_v2096 = globals.realtime
	bs_v2107 = bs_v450()
	bs_v2114 = bs_v2107.r
	bs_v2125 = bs_v2107.g
	bs_v2128 = bs_v2107.b
	bs_v2129 = bs_v2107.a
	bs_v2130 = {}

	for iter_657_0 = 0, bs_v327 - 1 do
		bs_v2074 = (bs_v300 - 1 + iter_657_0) % bs_v340 + 1
		bs_v2077 = bs_v285[bs_v2074]

		if bs_v2096 - bs_v2077.born < bs_v353 then
			bs_v2130[#bs_v2130 + 1] = bs_v2077
		end
	end

	bs_v285 = {}
	bs_v300 = 1
	bs_v314 = #bs_v2130
	bs_v327 = #bs_v2130

	for iter_657_1 = 1, #bs_v2130 do
		bs_v285[iter_657_1] = bs_v2130[iter_657_1]
	end

	bs_v2066 = entity.get_local_player()
	bs_v2067 = {}

	for iter_657_2 = 1, bs_v327 do
		bs_v2067[iter_657_2] = bs_v285[iter_657_2]
	end

	if bs_v2066 and bs_v2066:is_alive() then
		bs_v2069, bs_v2071 = pcall(function()
			return bs_v2066:get_origin()
		end)

		if bs_v2069 and bs_v2071 then
			bs_v2073 = true

			if #bs_v2067 > 0 then
				bs_v2076 = bs_v2067[#bs_v2067]
				bs_v2079 = bs_v2071.x - bs_v2076.x
				bs_v2081 = bs_v2071.y - bs_v2076.y
				bs_v2084 = bs_v2071.z + 18 - bs_v2076.z

				if bs_v2079 * bs_v2079 + bs_v2081 * bs_v2081 + bs_v2084 * bs_v2084 > 16384 then
					bs_v2073 = false
				end
			end

			if bs_v2073 then
				bs_v2067[#bs_v2067 + 1] = {
					x = bs_v2071.x,
					y = bs_v2071.y,
					z = bs_v2071.z + 18,
					born = bs_v2096
				}
			end
		end
	end

	bs_v2068 = #bs_v2067

	if bs_v2068 < 2 then
		return
	end

	bs_v2070 = {
		0
	}

	for iter_657_3 = 2, bs_v2068 do
		bs_v2083 = bs_v2067[iter_657_3 - 1]
		bs_v2086 = bs_v2067[iter_657_3]
		bs_v2070[iter_657_3] = bs_v2070[iter_657_3 - 1] + math.sqrt((bs_v2086.x - bs_v2083.x)^2 + (bs_v2086.y - bs_v2083.y)^2 + (bs_v2086.z - bs_v2083.z)^2)
	end

	bs_v2072 = math.max(0.001, bs_v2070[bs_v2068])

	function bs_v2075(arg_659_0, arg_659_1, arg_659_2, arg_659_3, arg_659_4, arg_659_5)
		local var_659_0 = (arg_659_3 - arg_659_0)^2 + (arg_659_4 - arg_659_1)^2 + (arg_659_5 - arg_659_2)^2

		return math.max(var_659_0^0.25, 1e-05)
	end

	function bs_v2078(arg_660_0, arg_660_1, arg_660_2, arg_660_3, arg_660_4)
		if math.abs(arg_660_3 - arg_660_2) < 1e-07 then
			return arg_660_0
		end

		return arg_660_0 + (arg_660_1 - arg_660_0) * (arg_660_4 - arg_660_2) / (arg_660_3 - arg_660_2)
	end

	function bs_v2080(arg_661_0, arg_661_1, arg_661_2, arg_661_3, arg_661_4, arg_661_5, arg_661_6, arg_661_7, arg_661_8)
		local var_661_0 = bs_v2078(arg_661_0, arg_661_1, arg_661_4, arg_661_5, arg_661_8)
		local var_661_1 = bs_v2078(arg_661_1, arg_661_2, arg_661_5, arg_661_6, arg_661_8)
		local var_661_2 = bs_v2078(arg_661_2, arg_661_3, arg_661_6, arg_661_7, arg_661_8)
		local var_661_3 = bs_v2078(var_661_0, var_661_1, arg_661_4, arg_661_6, arg_661_8)
		local var_661_4 = bs_v2078(var_661_1, var_661_2, arg_661_5, arg_661_7, arg_661_8)

		return bs_v2078(var_661_3, var_661_4, arg_661_5, arg_661_6, arg_661_8)
	end

	bs_v2082 = {
		[0] = {
			x = 2 * bs_v2067[1].x - bs_v2067[2].x,
			y = 2 * bs_v2067[1].y - bs_v2067[2].y,
			z = 2 * bs_v2067[1].z - bs_v2067[2].z,
			born = bs_v2067[1].born
		}
	}

	for iter_657_4 = 1, bs_v2068 do
		bs_v2082[iter_657_4] = bs_v2067[iter_657_4]
	end

	bs_v2082[bs_v2068 + 1] = {
		x = 2 * bs_v2067[bs_v2068].x - bs_v2067[bs_v2068 - 1].x,
		y = 2 * bs_v2067[bs_v2068].y - bs_v2067[bs_v2068 - 1].y,
		z = 2 * bs_v2067[bs_v2068].z - bs_v2067[bs_v2068 - 1].z,
		born = bs_v2067[bs_v2068].born
	}
	bs_v2085 = 2.5
	bs_v2088 = nil
	bs_v2089 = nil
	bs_v2090 = nil
	bs_v2091 = nil
	bs_v2092 = render.world_to_screen(vector(bs_v2067[bs_v2068].x, bs_v2067[bs_v2068].y, bs_v2067[bs_v2068].z))

	if bs_v2092 then
		bs_v2090, bs_v2091 = bs_v2092.x, bs_v2092.y
	end

	for iter_657_5 = 1, bs_v2068 - 1 do
		bs_v2095 = bs_v2082[iter_657_5 - 1]
		bs_v2097 = bs_v2082[iter_657_5]
		bs_v2098 = bs_v2082[iter_657_5 + 1]
		bs_v2099 = bs_v2082[iter_657_5 + 2]
		bs_v2100 = 0
		bs_v2101 = bs_v2100 + bs_v2075(bs_v2095.x, bs_v2095.y, bs_v2095.z, bs_v2097.x, bs_v2097.y, bs_v2097.z)
		bs_v2102 = bs_v2101 + bs_v2075(bs_v2097.x, bs_v2097.y, bs_v2097.z, bs_v2098.x, bs_v2098.y, bs_v2098.z)
		bs_v2103 = bs_v2102 + bs_v2075(bs_v2098.x, bs_v2098.y, bs_v2098.z, bs_v2099.x, bs_v2099.y, bs_v2099.z)
		bs_v2104 = bs_v2070[iter_657_5] / bs_v2072
		bs_v2105 = bs_v2070[iter_657_5 + 1] / bs_v2072
		bs_v2106 = math.sqrt((bs_v2098.x - bs_v2097.x)^2 + (bs_v2098.y - bs_v2097.y)^2 + (bs_v2098.z - bs_v2097.z)^2)
		bs_v2108 = math.max(4, math.min(48, math.ceil(bs_v2106 / bs_v2085)))
		bs_v2109 = math.max(bs_v2102 - bs_v2101, 1e-07)
		bs_v2110 = 1 / bs_v2108

		for iter_657_6 = 0, bs_v2108 - 1 do
			bs_v2111 = iter_657_6 * bs_v2110
			bs_v2112 = (iter_657_6 + 1) * bs_v2110
			bs_v2113 = bs_v2104 + (bs_v2105 - bs_v2104) * (bs_v2111 + bs_v2112) * 0.5
			bs_v2115 = bs_v2113 * bs_v2113 * (3 - 2 * bs_v2113)
			bs_v2116 = bs_v454(bs_v2129 * bs_v2115 * bs_v403)

			if bs_v2116 >= 4 then
				bs_v2117 = bs_v2101 + bs_v2111 * bs_v2109
				bs_v2118 = bs_v2101 + bs_v2112 * bs_v2109
				bs_v2119 = bs_v2080(bs_v2095.x, bs_v2097.x, bs_v2098.x, bs_v2099.x, bs_v2100, bs_v2101, bs_v2102, bs_v2103, bs_v2117)
				bs_v2120 = bs_v2080(bs_v2095.y, bs_v2097.y, bs_v2098.y, bs_v2099.y, bs_v2100, bs_v2101, bs_v2102, bs_v2103, bs_v2117)
				bs_v2121 = bs_v2080(bs_v2095.z, bs_v2097.z, bs_v2098.z, bs_v2099.z, bs_v2100, bs_v2101, bs_v2102, bs_v2103, bs_v2117)
				bs_v2122 = bs_v2080(bs_v2095.x, bs_v2097.x, bs_v2098.x, bs_v2099.x, bs_v2100, bs_v2101, bs_v2102, bs_v2103, bs_v2118)
				bs_v2123 = bs_v2080(bs_v2095.y, bs_v2097.y, bs_v2098.y, bs_v2099.y, bs_v2100, bs_v2101, bs_v2102, bs_v2103, bs_v2118)
				bs_v2124 = bs_v2080(bs_v2095.z, bs_v2097.z, bs_v2098.z, bs_v2099.z, bs_v2100, bs_v2101, bs_v2102, bs_v2103, bs_v2118)
				bs_v2126 = render.world_to_screen(vector(bs_v2119, bs_v2120, bs_v2121))
				bs_v2127 = render.world_to_screen(vector(bs_v2122, bs_v2123, bs_v2124))

				if bs_v2126 and bs_v2127 then
					bs_v457(bs_v2126.x, bs_v2126.y, bs_v2127.x, bs_v2127.y, bs_v2114, bs_v2125, bs_v2128, bs_v454(bs_v2116 * 0.7))

					bs_v2088, bs_v2089 = bs_v2127.x, bs_v2127.y
				end
			end
		end
	end

	bs_v2093 = bs_v2090 or bs_v2088
	bs_v2094 = bs_v2091 or bs_v2089

	if bs_v2093 then
		bs_v459(bs_v2093, bs_v2094, bs_v2114, bs_v2125, bs_v2128, bs_v454(bs_v2129 * bs_v403))
	end
end)

function bs_v463()
	bs_v285 = {}
	bs_v300 = 1
	bs_v314 = 0
	bs_v327 = 0
	bs_v386 = nil
	bs_v376 = 0
	bs_v394 = nil
	bs_v442 = false
	bs_v434 = -1000
end

events.round_start(bs_v463)
events.level_change(bs_v463)
events.player_death(function(arg_663_0)
	local var_663_0 = entity.get_local_player()

	if var_663_0 and entity.get(arg_663_0.userid, true) == var_663_0 then
		bs_v463()
	end
end)

bs_v166 = 0
bs_v190 = 46
bs_v212 = 4
bs_v232 = 7
bs_v252 = 16
bs_v270 = 14
bs_v284 = 26
bs_v299 = 240
bs_v313 = {}
bs_v326 = {}
bs_v339 = {}
bs_v352 = 0

function bs_v365(arg_664_0, arg_664_1, arg_664_2)
	arg_664_2 = math.max(0, math.min(1, arg_664_2))

	return arg_664_0 + (arg_664_1 - arg_664_0) * arg_664_2
end

function bs_v375(arg_665_0, arg_665_1, arg_665_2)
	arg_665_2 = math.max(0, math.min(1, arg_665_2))

	return color(math.floor(arg_665_0.r + (arg_665_1.r - arg_665_0.r) * arg_665_2), math.floor(arg_665_0.g + (arg_665_1.g - arg_665_0.g) * arg_665_2), math.floor(arg_665_0.b + (arg_665_1.b - arg_665_0.b) * arg_665_2), math.floor(arg_665_0.a + (arg_665_1.a - arg_665_0.a) * arg_665_2))
end

function bs_v385(arg_666_0, arg_666_1, arg_666_2, arg_666_3, arg_666_4, arg_666_5, arg_666_6)
	local var_666_0 = 16

	for iter_666_0 = 0, var_666_0 - 1 do
		local var_666_1 = iter_666_0 / var_666_0
		local var_666_2 = (iter_666_0 + 1) / var_666_0
		local var_666_3 = color(math.floor(arg_666_4.r + (arg_666_5.r - arg_666_4.r) * var_666_1), math.floor(arg_666_4.g + (arg_666_5.g - arg_666_4.g) * var_666_1), math.floor(arg_666_4.b + (arg_666_5.b - arg_666_4.b) * var_666_1), math.floor(arg_666_4.a + (arg_666_5.a - arg_666_4.a) * var_666_1))
		local var_666_4 = math.floor(arg_666_0 + var_666_1 * (arg_666_2 - arg_666_0))
		local var_666_5 = math.floor(arg_666_0 + var_666_2 * (arg_666_2 - arg_666_0))
		local var_666_6 = (iter_666_0 == 0 or iter_666_0 == var_666_0 - 1) and arg_666_6 or 0

		render.rect(vector(var_666_4, arg_666_1), vector(var_666_5, arg_666_3), var_666_3, var_666_6)
	end
end

function bs_v393(arg_667_0, arg_667_1, arg_667_2)
	render.line(vector(arg_667_0 - 7, arg_667_1 + 7), vector(arg_667_0 + 6, arg_667_1 - 6), arg_667_2)
	render.line(vector(arg_667_0 - 6, arg_667_1 + 7), vector(arg_667_0 + 6, arg_667_1 - 4), arg_667_2)
	render.line(vector(arg_667_0 - 7, arg_667_1 + 6), vector(arg_667_0 + 4, arg_667_1 - 6), arg_667_2)
	render.line(vector(arg_667_0 + 4, arg_667_1 - 6), vector(arg_667_0 + 9, arg_667_1 - 7), arg_667_2)
	render.line(vector(arg_667_0 + 4, arg_667_1 - 4), vector(arg_667_0 + 7, arg_667_1 - 7), arg_667_2)

	local var_667_0 = color(arg_667_2.r, arg_667_2.g, arg_667_2.b, math.floor(arg_667_2.a * 0.65))

	render.line(vector(arg_667_0 - 10, arg_667_1 + 9), vector(arg_667_0 - 7, arg_667_1 + 12), var_667_0)
	render.line(vector(arg_667_0 - 9, arg_667_1 + 9), vector(arg_667_0 - 6, arg_667_1 + 12), var_667_0)
	render.line(vector(arg_667_0 - 11, arg_667_1 + 7), vector(arg_667_0 - 9, arg_667_1 + 10), var_667_0)

	local var_667_1 = color(arg_667_2.r, arg_667_2.g, arg_667_2.b, math.floor(arg_667_2.a * 0.85))

	render.line(vector(arg_667_0 - 7, arg_667_1 + 4), vector(arg_667_0 - 4, arg_667_1 + 7), var_667_1)
end

bs_v402 = 160

function bs_v410(arg_668_0, arg_668_1, arg_668_2, arg_668_3, arg_668_4, arg_668_5, arg_668_6, arg_668_7, arg_668_8, arg_668_9, arg_668_10, arg_668_11, arg_668_12)
	bs_v2131 = arg_668_2 == "DT"
	bs_v2132 = render.measure_text(arg_668_12 or bs_ui_elements2, nil, arg_668_3)
	bs_v2133 = bs_v2131 and bs_v284 or 0
	bs_v2134 = bs_v270 + bs_v2133 + bs_v2132.x + bs_v270
	bs_v2135 = arg_668_0 + bs_v2134
	bs_v2136 = arg_668_1 + bs_v190
	bs_v2137 = math.floor(arg_668_6 * 255)

	if bs_v2137 < 2 then
		return
	end

	if arg_668_10 and bs_v2137 > 18 then
		render.blur(vector(arg_668_0, arg_668_1), vector(bs_v2135, bs_v2136), 7, arg_668_6 * 0.85, bs_v232)
	end

	bs_v2138 = math.floor(bs_v402 * arg_668_6)
	bs_v2139 = arg_668_0 + math.floor(bs_v2134 * 0.5)
	bs_v2140 = color(arg_668_7.r, arg_668_7.g, arg_668_7.b, 0)
	bs_v2141 = color(arg_668_7.r, arg_668_7.g, arg_668_7.b, bs_v2138)

	render.gradient(vector(arg_668_0, arg_668_1), vector(bs_v2139, bs_v2136), bs_v2140, bs_v2141, bs_v2140, bs_v2141)
	render.gradient(vector(bs_v2139, arg_668_1), vector(bs_v2135, bs_v2136), bs_v2141, bs_v2140, bs_v2141, bs_v2140)

	bs_v2142 = math.floor(arg_668_4.a * arg_668_6 * 0.12)

	if bs_v2142 > 3 then
		bs_v2144 = color(arg_668_4.r, arg_668_4.g, arg_668_4.b, 0)
		bs_v2146 = color(arg_668_4.r, arg_668_4.g, arg_668_4.b, bs_v2142)

		render.gradient(vector(arg_668_0, arg_668_1), vector(bs_v2139, bs_v2136), bs_v2144, bs_v2146, bs_v2144, bs_v2146)
		render.gradient(vector(bs_v2139, arg_668_1), vector(bs_v2135, bs_v2136), bs_v2146, bs_v2144, bs_v2146, bs_v2144)
	end

	render.rect_outline(vector(arg_668_0, arg_668_1), vector(bs_v2135, bs_v2136), color(arg_668_8.r, arg_668_8.g, arg_668_8.b, math.floor(arg_668_8.a * arg_668_6 * 0.45)), 1, bs_v232)
	render.gradient(vector(arg_668_0, arg_668_1), vector(bs_v2139, arg_668_1 + 1), color(255, 255, 255, 0), color(255, 255, 255, math.floor(arg_668_6 * 30)), color(255, 255, 255, 0), color(255, 255, 255, math.floor(arg_668_6 * 30)))
	render.gradient(vector(bs_v2139, arg_668_1), vector(bs_v2135, arg_668_1 + 1), color(255, 255, 255, math.floor(arg_668_6 * 30)), color(255, 255, 255, 0), color(255, 255, 255, math.floor(arg_668_6 * 30)), color(255, 255, 255, 0))

	bs_v2143 = math.floor(arg_668_4.a * arg_668_6)
	bs_v2145 = color(arg_668_4.r, arg_668_4.g, arg_668_4.b, bs_v2143)

	if bs_v2131 then
		bs_v2148 = arg_668_0 + bs_v270 + math.floor(bs_v284 * 0.5) - 1
		bs_v2150 = arg_668_1 + math.floor(bs_v190 * 0.5) - 3

		if arg_668_2 == "DT" then
			bs_v393(bs_v2148, bs_v2150, bs_v2145)
		end
	end

	bs_v2147 = arg_668_1 + math.floor((bs_v190 - bs_v2132.y) * 0.5)
	bs_v2149 = arg_668_0 + bs_v270 + bs_v2133
	bs_v2151 = math.floor(bs_v2143 * 0.45)

	if bs_v2151 > 3 then
		render.text(arg_668_12 or bs_ui_elements2, vector(bs_v2149 + 1, bs_v2147 + 1), color(0, 0, 0, bs_v2151), nil, arg_668_3)
	end

	render.text(arg_668_12 or bs_ui_elements2, vector(bs_v2149, bs_v2147), bs_v2145, nil, arg_668_3)
end

events.render(function()
	bs_v2152 = bs_ui_elements

	if not pcall(function()
		bs_v2152.enabled:get()
	end) then
		return
	end

	if not bs_v2152.enabled:get() then
		bs_v2164 = {}

		for iter_669_0 in pairs(bs_v313) do
			bs_v2164[#bs_v2164 + 1] = iter_669_0
		end

		for iter_669_1, iter_669_2 in ipairs(bs_v2164) do
			bs_v313[iter_669_2] = nil
			bs_v326[iter_669_2] = nil
			bs_v339[iter_669_2] = nil
		end

		return
	end

	bs_v2163 = entity.get_local_player()

	if not bs_v2163 or not bs_v2163:is_alive() then
		return
	end

	bs_v2181 = render.screen_size()
	bs_v2199 = globals.frametime
	bs_v2207 = math.min(1, bs_v2199 * 14)
	bs_v2208 = math.min(1, bs_v2199 * 7)
	bs_v2209 = bs_v2152.blur and bs_v2152.blur:get() or false
	bs_v2210 = bs_v2152.font and (function()
		local var_671_0, var_671_1 = pcall(function()
			return bs_v2152.font:get()
		end)

		return var_671_0 and var_671_1 == "verdana"
	end)() and bs_font_24b or bs_ui_elements2
	bs_v2153 = bs_v2152.col_bg:get()
	bs_v2154 = bs_v2152.col_border:get()
	bs_v2155 = bs_v2152.col_text:get()
	bs_v2156, bs_v2157 = pcall(function()
		return bs_config.rage.main.double_tap:get()
	end)
	bs_v2158, bs_v2159 = pcall(function()
		return bs_config.rage.main.hide_shots:get()
	end)
	bs_v2160, bs_v2161 = pcall(function()
		return rage.exploit:get()
	end)
	bs_v2162 = true
	bs_v2165 = bs_freestanding.think()
	bs_v2166, bs_v2167 = pcall(function()
		return bs_config.antiaim.misc.fake_duck:get()
	end)
	bs_v2168, bs_v2169 = pcall(function()
		return bs_config.rage.main.dormant_aimbot:get()
	end)
	bs_v2170 = bs_v2160 and type(bs_v2161) == "number" and bs_v2161 or 0
	bs_v2171 = bs_auto_hide_shots.is_active
	bs_v2172 = {}

	if bs_v2152.show_dt:get() and bs_v2156 and bs_v2157 and not bs_v2171 then
		bs_v2176 = bs_v2170 > 0.01 and bs_v2152.col_dt_on:get() or bs_v2152.col_dt_off:get()
		bs_v2172[#bs_v2172 + 1] = {
			label = "DT",
			key = "DT",
			rc = bs_v2176,
			fill_t = bs_v2170,
			charge_t = bs_v2170
		}
		
		-- Tickbase counter
		if bs_v2152.show_tickbase:get() then
			local lp = entity.get_local_player()
			if lp then
				local tb = lp.m_nTickBase
				if tb then
					local shift_cap = cvar.sv_maxusrcmdprocessticks:int() - 2
					pcall(function()
						local ab = bs_v621 and bs_v621.aimbot
						if ab and ab.dt_modifier_mode then
							local m = ab.dt_modifier_mode:get()
							if m == "Custom" then
								shift_cap = math.min(ab.dt_modifier_custom:get(), cvar.sv_maxusrcmdprocessticks:int())
							elseif m == "Instant" then
								shift_cap = 15
							end
						end
					end)
					local shift = math.floor(bs_v2170 * shift_cap)
					bs_v2172[#bs_v2172 + 1] = {
						label = "TB: " .. shift,
						key = "TICKBASE",
						rc = bs_v2152.col_text:get(),
						fill_t = 1
					}
				end
			end
		end
	end

	if bs_v2152.show_hs:get() and (bs_v2158 and bs_v2159 or bs_v2171) then
		bs_v2172[#bs_v2172 + 1] = {
			label = "HS",
			fill_t = 1,
			key = "HS",
			rc = bs_v2152.col_hs_on:get()
		}
	end

	if bs_v2152.show_fs:get() and bs_v2162 and bs_v2165 then
		bs_v2172[#bs_v2172 + 1] = {
			label = "FS",
			fill_t = 1,
			key = "FS",
			rc = bs_v2152.col_fs_on:get()
		}
	end

	if bs_v2152.show_fd:get() and bs_v2166 and bs_v2167 then
		bs_v2172[#bs_v2172 + 1] = {
			label = "FD",
			fill_t = 1,
			key = "FD",
			rc = bs_v2152.col_fd_on:get()
		}
	end

	if bs_v2152.show_da:get() and bs_v2168 and bs_v2169 then
		bs_v2172[#bs_v2172 + 1] = {
			label = "DA",
			fill_t = 1,
			key = "DA",
			rc = bs_v2152.col_da_on:get()
		}
	end

	if bs_v2152.show_ping and bs_v2152.show_ping:get() then
		bs_v2175, bs_v2180 = pcall(function()
			return bs_config.ping_spike:get()
		end)

		if bs_v2175 and type(bs_v2180) == "number" and bs_v2180 > 0 then
			bs_v2172[#bs_v2172 + 1] = {
				label = "PING",
				fill_t = 1,
				key = "PING",
				rc = bs_v2152.col_ping_on and bs_v2152.col_ping_on:get() or color(175, 175, 180, 255)
			}
		end
	end

	if bs_v2152.show_lc and bs_v2152.show_lc:get() and not (bs_v2166 and bs_v2167) then
		bs_v2179 = bs_v2163.m_fFlags
		bs_v2184 = bs_v2163.m_vecVelocity
		bs_v2187 = math.sqrt(bs_v2184.x * bs_v2184.x + bs_v2184.y * bs_v2184.y)
		bs_v2190 = bs_v2179 ~= 257 and bs_v2179 ~= 263

		if bs_v2190 then
			bs_v352 = 0.2
		else
			bs_v352 = math.max(0, bs_v352 - bs_v2199)
		end

		if bs_v2190 or bs_v352 > 0 then
			bs_v2193 = bs_v2187 >= 270 and globals.choked_commands > 2 and (bs_v2152.col_lc_on and bs_v2152.col_lc_on:get() or color(127, 189, 20, 255)) or bs_v2152.col_lc_bad and bs_v2152.col_lc_bad:get() or color(255, 0, 0, 255)
			bs_v2172[#bs_v2172 + 1] = {
				label = "LC",
				fill_t = 1,
				key = "LC",
				rc = bs_v2193
			}
		end
	end

	if bs_v2152.show_dmg:get() then
		bs_v2174 = bs_v2163:get_player_weapon()
		bs_v2178 = bs_v2174 and bs_v2174:get_classname() or ""
		bs_v2183 = bs_v2178:find("knife") or bs_v2178:find("bayonet") or bs_v2178 == "weapon_knifegg"
		bs_v2186 = bs_v2178:find("taser")

		if not bs_v2183 and not bs_v2186 then
			bs_v2189, bs_v2192 = pcall(function()
				return bs_config.rage.selection.minimum_damage:get()
			end)
			bs_v2195 = bs_hotkeys:is_active("min. damage")

			if not bs_v2195 then
				bs_v2197, bs_v2198 = pcall(function()
					return bs_config.rage.selection.minimum_damage_global:get()
				end)
				bs_v2195 = bs_v2197 and bs_v2198 == true
			end

			if bs_v2195 and bs_v2189 and bs_v2192 then
				bs_v2172[#bs_v2172 + 1] = {
					fill_t = 1,
					key = "DMG",
					label = tostring(math.floor(bs_v2192)),
					rc = bs_v2152.col_dmg_on:get()
				}
			end
		end
	end

	bs_v2173 = {}

	for iter_669_3, iter_669_4 in ipairs(bs_v2172) do
		bs_v2173[iter_669_4.key] = true
	end

	bs_v2177 = {
		DT = bs_v2152.show_dt:get(),
		HS = bs_v2152.show_hs:get(),
		FS = bs_v2152.show_fs:get(),
		FD = bs_v2152.show_fd:get(),
		DA = bs_v2152.show_da:get(),
		LC = bs_v2152.show_lc and bs_v2152.show_lc:get(),
		DMG = bs_v2152.show_dmg:get(),
		PING = bs_v2152.show_ping and bs_v2152.show_ping:get(),
		TICKBASE = bs_v2152.show_tickbase and bs_v2152.show_tickbase:get()
	}
	bs_v2182 = {}

	for iter_669_5 in pairs(bs_v313) do
		if not bs_v2173[iter_669_5] then
			if bs_v2177[iter_669_5] == false then
				bs_v2182[#bs_v2182 + 1] = iter_669_5
			else
				bs_v313[iter_669_5] = bs_v365(bs_v313[iter_669_5], 0, bs_v2207)
				bs_v326[iter_669_5] = bs_v365(bs_v326[iter_669_5] or 0, -bs_v299, bs_v2207)
				bs_v339[iter_669_5] = bs_v365(bs_v339[iter_669_5] or 0, 0, bs_v2208)

				if bs_v313[iter_669_5] < 0.015 then
					bs_v2182[#bs_v2182 + 1] = iter_669_5
				end
			end
		end
	end

	for iter_669_6, iter_669_7 in ipairs(bs_v2182) do
		bs_v313[iter_669_7] = nil
		bs_v326[iter_669_7] = nil
		bs_v339[iter_669_7] = nil
	end

	for iter_669_8, iter_669_9 in ipairs(bs_v2172) do
		if not bs_v313[iter_669_9.key] then
			bs_v313[iter_669_9.key] = 0
			bs_v326[iter_669_9.key] = -bs_v299
			bs_v339[iter_669_9.key] = 0
		end

		bs_v313[iter_669_9.key] = bs_v365(bs_v313[iter_669_9.key], 1, bs_v2207)
		bs_v326[iter_669_9.key] = bs_v365(bs_v326[iter_669_9.key], 0, bs_v2207)
		bs_v339[iter_669_9.key] = bs_v365(bs_v339[iter_669_9.key], iter_669_9.fill_t, bs_v2208)
	end

	bs_v2185 = #bs_v2172

	for iter_669_10 in pairs(bs_v313) do
		if not bs_v2173[iter_669_10] and (bs_v313[iter_669_10] or 0) >= 0.015 then
			bs_v2185 = bs_v2185 + 1
		end
	end

	bs_v2188 = bs_v2185 * bs_v190 + math.max(0, bs_v2185 - 1) * bs_v212
	bs_v2191 = math.floor(bs_v2181.y * 0.5 - bs_v2188 * 0.5)
	bs_v2194 = 0

	for iter_669_11, iter_669_12 in ipairs(bs_v2172) do
		bs_v2200 = bs_v313[iter_669_12.key] or 0
		bs_v2202 = bs_v326[iter_669_12.key] or 0
		bs_v2204 = bs_v339[iter_669_12.key] or 0
		bs_v2206 = bs_v2191 + bs_v2194 * (bs_v190 + bs_v212)

		bs_v410(bs_v252 + math.floor(bs_v2202), bs_v2206, iter_669_12.key, iter_669_12.label, iter_669_12.rc, bs_v2204, bs_v2200, bs_v2153, bs_v2154, bs_v2155, bs_v2209, iter_669_12.charge_t, bs_v2210)

		bs_v2194 = bs_v2194 + 1
	end

	bs_v2196 = bs_v2152.col_off:get()

	for iter_669_13, iter_669_14 in pairs(bs_v313) do
		if not bs_v2173[iter_669_13] and iter_669_14 and iter_669_14 >= 0.015 and bs_v2177[iter_669_13] ~= false then
			bs_v2201 = bs_v326[iter_669_13] or 0
			bs_v2203 = bs_v339[iter_669_13] or 0
			bs_v2205 = bs_v2191 + bs_v2194 * (bs_v190 + bs_v212)

			bs_v410(bs_v252 + math.floor(bs_v2201), bs_v2205, iter_669_13, iter_669_13, bs_v2196, bs_v2203, iter_669_14, bs_v2153, bs_v2154, bs_v2155, bs_v2209, nil, bs_v2210)

			bs_v2194 = bs_v2194 + 1
		end
	end
end)
events.render(function()
	bs_v166 = bs_v166 + globals.frametime
	bs_v2211, bs_v2212 = pcall(function()
		return bs_v479:get()
	end)
	bs_v2212 = bs_v2211 and bs_v2212 or color(107, 112, 147, 255)
	bs_v2228 = bs_v2212.r
	bs_v2230 = bs_v2212.g
	bs_v2231 = bs_v2212.b
	bs_v2232 = bs_v1
	bs_v2233 = #bs_v2232
	bs_v2234 = ""
	bs_v2235 = bs_v166 * 0.5 % 1.3 - 0.15

	for iter_681_0 = 1, bs_v2233 do
		bs_v2218 = (iter_681_0 - 1) / math.max(bs_v2233 - 1, 1)
		bs_v2220 = math.abs(bs_v2218 - bs_v2235)
		bs_v2222 = math.max(0, 1 - bs_v2220 / 0.12)
		bs_v2221 = bs_v2222 * bs_v2222 * bs_v2222 * bs_v2222
		bs_v2224 = math.max(0, 1 - bs_v2220 / 0.5)
		bs_v2223 = bs_v2224 * bs_v2224 * 0.35
		bs_v2225 = math.min(1, bs_v2221 * 1 + bs_v2223)
		bs_v2226 = math.max(0, math.min(255, math.floor(8 + (bs_v2228 - 8) * bs_v2225 + 0.5)))
		bs_v2227 = math.max(0, math.min(255, math.floor(8 + (bs_v2230 - 8) * bs_v2225 + 0.5)))
		bs_v2229 = math.max(0, math.min(255, math.floor(8 + (bs_v2231 - 8) * bs_v2225 + 0.5)))
		bs_v2234 = bs_v2234 .. string.format("\a%02x%02x%02xff%s", bs_v2226, bs_v2227, bs_v2229, bs_v2232:sub(iter_681_0, iter_681_0))
	end

	bs_v2236 = bs_v166 * 0.45 % 1
	bs_v2213 = 0

	if bs_v2236 < 0.2 then
		bs_v2215 = bs_v2236 / 0.2
		bs_v2213 = math.sin(bs_v2215 * math.pi)
		bs_v2213 = bs_v2213 * bs_v2213 * bs_v2213 * bs_v2213
	end

	bs_v2214 = math.max(0, math.min(255, math.floor(8 + (bs_v2228 - 8) * bs_v2213 + 0.5)))
	bs_v2216 = math.max(0, math.min(255, math.floor(8 + (bs_v2230 - 8) * bs_v2213 + 0.5)))
	bs_v2217 = math.max(0, math.min(255, math.floor(8 + (bs_v2231 - 8) * bs_v2213 + 0.5)))
	bs_v2219 = string.format("\a%02x%02x%02xff✦", bs_v2214, bs_v2216, bs_v2217)

	ui.sidebar("\a00000000     " .. bs_v2219 .. " " .. bs_v2234, " ")
end)

-- DT Modifier callback & runtime
bs_v718.dt_modifier:set_callback(function(e)
	bs_v718.dt_modifier_mode:visibility(e:get())
	bs_v718.dt_modifier_custom:visibility(e:get() and bs_v718.dt_modifier_mode:get() == "Custom")
end)

events.createmove(function(cmd)
	if not bs_v621.aimbot.dt_modifier:get() then return end
	if not (bs_config.rage.main.double_tap and bs_config.rage.main.double_tap:get()) then return end
	if not cmd.in_attack then return end
	
	-- Only apply when DT is charged and ready to fire (exploit == 1)
	local exploit = rage.exploit
	if not exploit or exploit:get() ~= 1 then return end
	
local max_ticks = cvar.sv_maxusrcmdprocessticks:int()
	local safe_max = max_ticks - 2
	local instant_max = 15

	local ticks = 0
	local mode = bs_v621.aimbot.dt_modifier_mode:get()
	if mode == "Instant" then
		ticks = instant_max
	elseif mode == "Normal" then
		ticks = math.min(14, safe_max)
	elseif mode == "Custom" then
		ticks = math.min(bs_v621.aimbot.dt_modifier_custom:get(), max_ticks)
	end
	
	if ticks > 0 then
		cmd.tickcount = (cmd.tickcount or 0) + ticks
	end
end)

-- AimBot HC conditions runtime: applies the global condition-based hitchance
-- override and feeds the ESP flag. Enemy roster is refreshed from entity.get_players
-- each tick so defensive detection and the state conditions have live data.
do
	local S = {
		enemies = {},            -- [idx] = { ent, name, hp, armor, alive, dormant, def, detected_until, samples, last_seen }
		hc_ref = nil,
		active_hc = nil,
		autoscope_script_owned = false,
		last_shot_time = 0,
		stand_dwell = {},
		esp_flag = nil,
	}

	local function find_first(paths)
		for _, path in ipairs(paths) do
			local ok, r = pcall(ui.find, unpack(path))
			if ok and r then return r end
		end
		return nil
	end
	local function hc_ref()
		if S.hc_ref then return S.hc_ref end
		S.hc_ref = find_first({
			{ "Aimbot", "Ragebot", "Selection", "Hit Chance" },
			{ "Aimbot", "Ragebot", "Selection", "Global", "Hit Chance" },
		})
		return S.hc_ref
	end

	local function release_overrides()
		if S.hc_ref and S.active_hc then pcall(function() S.hc_ref:override(nil) end) end
		S.active_hc = nil
	end

	local function enemy_index(p)
		local ok, i = pcall(function() return p:get_index() end)
		if not ok or not i then ok, i = pcall(function() return p:get_entindex() end) end
		if not ok or not i then i = tostring(p) end
		return i
	end
	local function enemy_name(p)
		local ok, n = pcall(function() return p:get_name() end)
		return (ok and n) and n or "?"
	end
	local function read_hp(p)
		local ok, h = pcall(function() return tonumber(p.m_iHealth) end)
		return (ok and h) and h or 0
	end
	-- Armor value: 0 means no kevlar (body shots land at full damage).
	local function read_armor(p)
		local ok, a = pcall(function() return tonumber(p.m_ArmorValue) end)
		return (ok and a) and a or 0
	end

	-- Defensive detection per enemy: eye-angle jitter only.
	-- (The old m_flSimulationTime jump heuristic false-flagged fakelag players.)
	local function update_defensive(p, idx, now)
		local rec = S.enemies[idx]
		if not rec then
			rec = { name = "?", hp = 0, armor = 0, def = false, detected_until = 0, samples = {} }
			S.enemies[idx] = rec
		end
		local nm = enemy_name(p)
		if nm and nm ~= "?" then rec.name = nm end
		rec.ent = p
		rec.hp = read_hp(p)
		rec.armor = read_armor(p)
		local ok_a, al = pcall(function() return p:is_alive() end)
		rec.alive = ok_a and (al == true) or false
		local ok_dm, dm = pcall(function() return p:is_dormant() end)
		rec.dormant = (ok_dm and dm) and true or false
		rec.last_seen = now

		local defensive = false
		local pitch, yaw
		pcall(function()
			local a = p.m_angEyeAngles
			if a then pitch, yaw = tonumber(a.x or a[1]), tonumber(a.y or a[2]) end
		end)
		if not pitch or not yaw then
			pcall(function()
				local ok, a = p:get_eye_angles()
				if ok and a then pitch, yaw = tonumber(a.x or a[1]), tonumber(a.y or a[2]) end
			end)
		end

		local samples = rec.samples
		if pitch and yaw then
			samples[#samples + 1] = { pitch = pitch, yaw = yaw, time = now }
			while #samples > 10 or (#samples > 0 and now - samples[1].time > 0.9) do
				table.remove(samples, 1)
			end
			local pj, yj = 0, 0
			local pv, yv = {}, {}
			for si, s in ipairs(samples) do
				pv[math.floor(s.pitch / 20 + 0.5)] = true
				yv[math.floor(s.yaw / 35 + 0.5)] = true
				if si > 1 then
					local pr = samples[si - 1]
					if math.abs(s.pitch - pr.pitch) > 18 then pj = pj + 1 end
					if math.abs((s.yaw - pr.yaw + 180) % 360 - 180) > 35 then yj = yj + 1 end
				end
			end
			local pc, yc = 0, 0
			for _ in pairs(pv) do pc = pc + 1 end
			for _ in pairs(yv) do yc = yc + 1 end
			if #samples >= 6 and ((pj >= 3 and yj >= 3) or (pc >= 3 and yj >= 4) or (yc >= 4 and pj >= 3)) then
				rec.detected_until = now + 0.35
			end
		end

		rec.def = defensive or (rec.detected_until or 0) > now
		return rec
	end

	-- Refresh the enemy roster (includes dormant) so every condition has data.
	local function update_enemies(now)
		local ok, players = pcall(entity.get_players, true, true)
		if not ok or type(players) ~= "table" then return end
		local seen = {}
		for _, p in ipairs(players) do
			if p ~= nil then
				local idx = enemy_index(p)
				seen[idx] = true
				update_defensive(p, idx, now)
			end
		end
		for idx in pairs(S.enemies) do
			if not seen[idx] then S.enemies[idx] = nil end
		end
	end

	-- Resolve the target state used by the HC condition overrides.
	local function resolve_state(rec, local_player, threat, wc)
		local lp_pos = nil
		pcall(function() lp_pos = local_player:get_origin() end)
		local scoped_weapon = (wc == "awp" or wc == "scout" or wc == "auto")
		local state = nil
		local function eligible(st)
			local en = bs_v718.hc_cond_state_en and bs_v718.hc_cond_state_en[st]
			local enabled = false
			pcall(function() enabled = en and en:get() end)
			if not enabled then return false end
			local sl = bs_v718.hc_cond_state_sl and bs_v718.hc_cond_state_sl[st]
			local wsl = sl and sl[wc]
			local wpen = bs_v718.hc_cond_state_wpn and bs_v718.hc_cond_state_wpn[st] and bs_v718.hc_cond_state_wpn[st][wc]
			local wpen_on = true
			if wpen then pcall(function() wpen_on = wpen:get() end) end
			if not wpen_on then return false end
			local val = 0
			pcall(function() val = wsl and wsl:get() or 0 end)
			if not (val and val > 0) then return false end
			return true
		end
		-- No Scope: scoped weapon + not scoped + past the per-weapon re-scope window.
		if scoped_weapon then
			local scoped = true
			local ok, value = pcall(function()
				return local_player.m_bIsScoped
			end)
			if ok and type(value) == "boolean" then
				scoped = value
			end
			local auto_scope = false
			local auto_scope_ref = bs_config and bs_config.rage and bs_config.rage.selection and bs_config.rage.selection.autoscope
			if auto_scope_ref then
				local ok, val = pcall(function() return auto_scope_ref:get() end)
				if ok then auto_scope = (val == true) end
			end
			local dist = 0
			if not scoped then
				local now = globals.curtime or 0
				local cooldown = 1.0
				if wc == "awp" then cooldown = 1.95
				elseif wc == "scout" then cooldown = 1.75
				elseif wc == "auto" then cooldown = 0.75 end
				if (now - (S.last_shot_time or 0)) > cooldown then
					local ep = nil
					pcall(function() ep = threat:get_origin() end)
					if lp_pos and ep then
						local dx = ep.x - lp_pos.x
						local dy = ep.y - lp_pos.y
						local dz = ep.z - lp_pos.z
						dist = math.sqrt(dx * dx + dy * dy + dz * dz)
					end
				end
			end
			local limit = 255
			if wc == "auto" then limit = 765 end
if not scoped and not auto_scope and dist and dist <= limit and dist > 0 and eligible("noscope") then state = "noscope" end
	end

	-- Enemy HP threshold (wins over all except noscope)
	if not state then
		local thr = 50
		pcall(function()
			local s = bs_v718.hc_cond_hp_threshold and bs_v718.hc_cond_hp_threshold[wc or "awp"]
			thr = s and s:get() or 50
		end)
	local ehp = (rec and rec.hp) or 0
	local e_dist = 0
	pcall(function()
		local ep = threat:get_origin()
		if lp_pos and ep then
			local dx = ep.x - lp_pos.x
			local dy = ep.y - lp_pos.y
			local dz = ep.z - lp_pos.z
			e_dist = math.sqrt(dx*dx + dy*dy + dz*dz)
		end
	end)
	if thr > 0 and ehp > 0 and ehp <= thr and e_dist <= 380 and eligible("enemyhp") then state = "enemyhp" end
	end


		-- Shared vertical / distance data for Below, Air and Above.
		local lp_z = (lp_pos and lp_pos.z) or 0
		local ep_z = 0
		pcall(function() ep_z = threat:get_origin().z end)
		local above_dist = 0
		if lp_pos then
			local ep = nil
			pcall(function() ep = threat:get_origin() end)
			if ep then
				local dx = ep.x - lp_pos.x
				local dy = ep.y - lp_pos.y
				local dz = ep.z - lp_pos.z
				above_dist = math.sqrt(dx * dx + dy * dy + dz * dz)
			end
		end

-- Above
-- Above
local grounded = false
pcall(function() grounded = bit.band(threat.m_fFlags or 0, 1) == 1 end)
if not state and ep_z and lp_z and ep_z > lp_z + 60 and above_dist <= 4000 and grounded and eligible("above") then state = "above" end
-- Below
-- Below
if not state and ep_z and lp_z and ep_z < lp_z - 65 and eligible("below") then state = "below" end
-- LC/Defensive
if not state and rec and rec.def and eligible("lc") then state = "lc" end
-- In Air
if not state then
	local in_air = false
	pcall(function() in_air = not bit.band(threat.m_fFlags or 0, 1) == 1 end)
	if in_air then
		local air_dist = 0
		if lp_pos then
			local ep = nil
			pcall(function() ep = threat:get_origin() end)
			if ep then
				local dx = ep.x - lp_pos.x
				local dy = ep.y - lp_pos.y
				local dz = ep.z - lp_pos.z
				air_dist = math.sqrt(dx * dx + dy * dy + dz * dz)
			end
		end
		if air_dist <= 1000 and air_dist >= 144 and eligible("air") then state = "air" end
	end
end
		-- Standing: enemy horizontal velocity < 1 for >0.9s (dwell time).
		if not state then
			local grounded = false
			pcall(function() grounded = bit.band(threat.m_fFlags or 0, 1) == 1 end)
			local local_grounded = false
			pcall(function() local_grounded = bit.band(local_player.m_fFlags or 0, 1) == 1 end)
			if grounded then
				local vel = 0
			pcall(function()
				vel = threat.m_vecVelocity and (threat.m_vecVelocity.x * threat.m_vecVelocity.x + threat.m_vecVelocity.y * threat.m_vecVelocity.y) or 0
			end)
			local now = globals.curtime or 0
			local key = tostring(threat)
			S.stand_dwell = S.stand_dwell or {}
			if vel >= 1 then
				S.stand_dwell[key] = now
			else
				S.stand_dwell[key] = S.stand_dwell[key] or now
				if (now - S.stand_dwell[key]) >= 0.9 and eligible("stand") then state = "stand" end
			end
			end
		end
		-- Enemy moving (in air or moving)
		if not state then
			local evel = 0
			pcall(function()
				local vel = threat.m_vecVelocity
				if vel then evel = (vel.x * vel.x + vel.y * vel.y) end
			end)
			local inair = false
			pcall(function() inair = not bit.band(threat.m_fFlags or 0, 1) == 1 end)
			if inair or evel >= 100 then if eligible("enemymove") then state = "enemymove" end end
		end

				return state
	end

	-- Resolve the condition-based hitchance for the current threat.
	local function decide_for_threat(rec, local_player, threat)
		local cond_hc = 0
		local state = nil
		local wc = bs_select_weapon_class()
		if bs_v718.hc_conditions and bs_v718.hc_conditions:get() and threat then
			local hc_weapon = (wc == "awp" or wc == "scout" or wc == "auto")
			if hc_weapon then
				state = resolve_state(rec, local_player, threat, wc)
				if state then
					local en = bs_v718.hc_cond_state_en[state]
					local sl = bs_v718.hc_cond_state_sl[state]
					local enabled = false
					pcall(function() enabled = en and en:get() end)
					if enabled and sl then
						local wsl = sl[wc]
						local wpen = bs_v718.hc_cond_state_wpn and bs_v718.hc_cond_state_wpn[state] and bs_v718.hc_cond_state_wpn[state][wc]
						local wpen_on = true
						if wpen then pcall(function() wpen_on = wpen:get() end) end
						if wpen_on then
							pcall(function() cond_hc = wsl and wsl:get() or 0 end)
						end
					end
				end
			end
		end
		bs_active_hc_state = state
		return (cond_hc and cond_hc > 0) and cond_hc or 0
	end

	local function apply_threat_overrides(local_player, threat)
		if not (threat and threat:is_alive()) then
			-- No active threat: fall back to any alive, non-dormant enemy.
			for _, rec in pairs(S.enemies or {}) do
				if rec.alive and not rec.dormant and rec.ent then
					local ok, isAlive = pcall(function() return rec.ent:is_alive() end)
					if ok and isAlive then threat = rec.ent; break end
				end
			end
			if not (threat and threat:is_alive()) then
				release_overrides()
				bs_active_hc_value = 0
				return
			end
		end
		local idx = enemy_index(threat)
		local rec = S.enemies[idx]
		if not rec then
			rec = { name = "?", hp = 0, armor = 0, def = false, detected_until = 0, samples = {}, ent = threat }
			S.enemies[idx] = rec
		end

		local hc = decide_for_threat(rec, local_player, threat)
		local href = hc_ref()
		local want_hc = (hc and hc > 0) and hc or nil
		if href and S.active_hc ~= want_hc then
			if S.active_hc then
				local ok_clear = pcall(function() href:override(nil) end)
				if not ok_clear then return end
			end
			if want_hc then
				local ok = pcall(function() href:override(want_hc) end)
				S.active_hc = ok and want_hc or S.active_hc
			else
				S.active_hc = nil
			end
		end
		bs_active_hc_value = S.active_hc or 0
	end

	-- ESP flag: shows HC and DEF states above each enemy.
	local ok_esp, esp_obj = pcall(function()
		return esp.enemy:new_text("Bluesense", "Bluesense", function(ent)
			local ok_master, master = pcall(function()
				local hc_on = false
				pcall(function() hc_on = bs_v718.hc_conditions:get() end)
				return hc_on
			end)
			if not ok_master or not master then return end
			if not ent or ent:is_dormant() then return end
			local rec = S.enemies[enemy_index(ent)]
			local parts = {}
			local display_hc = bs_active_hc_value or 0
			if display_hc <= 0 then
				local ok_rhc, val_rhc = pcall(function() return bs_config.rage.selection.hit_chance:get() end)
				if ok_rhc and val_rhc then display_hc = val_rhc end
			end
			if display_hc > 0 then parts[#parts + 1] = "HC" .. tostring(display_hc) end
			if rec and rec.def then parts[#parts + 1] = "DEF" end
			if #parts == 0 then return end
			return "[" .. table.concat(parts, " ") .. "]"
		end):create()
	end)
	if ok_esp and esp_obj then
		S.esp_flag = esp_obj
	end

	local function reset()
		S.enemies = {}
		S.stand_dwell = {}
		release_overrides()
		bs_active_hc_value = 0
		bs_active_hc_state = nil
	end

	events.createmove(function(cmd)
		local attack_held = cmd and cmd.buttons and bit.band(cmd.buttons, 1) ~= 0
		if attack_held and not S.last_attack_held then
			S.last_shot_time = globals.curtime or 0
		end
		S.last_attack_held = attack_held
		local local_player = entity.get_local_player()
		local alive = false
		if local_player then
			local ok_al, al = pcall(function() return local_player:is_alive() end)
			alive = ok_al and al == true
		end

		if not alive then
			release_overrides()
			S.enemies = {}
			bs_active_hc_value = 0
			return
		end

		update_enemies(globals.curtime or 0)

		local threat = nil
		local ok, t = pcall(entity.get_threat)
		if ok and t then threat = t end
		if not threat then
			ok, t = pcall(rage.antiaim.get_target, rage.antiaim)
			if ok and t then threat = t end
		end

-- Auto Scope: enable/disable based on valid threat lifecycle.
do
	local ref = bs_config and bs_config.rage and bs_config.rage.selection and bs_config.rage.selection.autoscope
	if ref then
		local ok_cur, cur = pcall(function() return ref:get() end)
		if ok_cur then
			if S.autoscope_script_owned and cur == false then
				S.autoscope_script_owned = false
			end
		end
	end
end

local autoscope_should_enable = false
if threat and threat:is_alive() then
	local wc = bs_select_weapon_class()
	if wc == "awp" or wc == "scout" or wc == "auto" then
		local dormant = false
		pcall(function() dormant = threat:is_dormant() end)
		if not dormant then
			local lp_pos = nil
			pcall(function() lp_pos = local_player:get_origin() end)
			local ep = nil
			pcall(function() ep = threat:get_origin() end)
			local dist = nil
			if lp_pos and ep then
				local dx = ep.x - lp_pos.x
				local dy = ep.y - lp_pos.y
				local dz = ep.z - lp_pos.z
				dist = math.sqrt(dx*dx + dy*dy + dz*dz)
			end
			local limit = 255
			if wc == "auto" then limit = 765 end
			if dist and dist > limit then
				autoscope_should_enable = true
			end
		end
	end
end

local ref = bs_config and bs_config.rage and bs_config.rage.selection and bs_config.rage.selection.autoscope
if ref then
	if autoscope_should_enable then
		local ok, cur = pcall(function() return ref:get() end)
		if ok and cur == false then
			local ok_set = pcall(function() ref:set(true) end)
			if ok_set then S.autoscope_script_owned = true end
		end
	else
		if S.autoscope_script_owned then
			pcall(function() ref:set(false) end)
			S.autoscope_script_owned = false
		end
	end
end
		apply_threat_overrides(local_player, threat)
	end)

	events.level_change(reset)
	events.shutdown(reset)
end
-- Force Shoot runtime
do
	local fs = bs_v621.aimbot
	local force_shoot_runtime = {
		last_shot_tick = 0,
		last_enemy_shot_tick = 0,
		peek_state = false
	}

	events.createmove(function(cmd)
		if not fs.force_shoot:get() or globals.is_in_game ~= true then
			force_shoot_runtime.peek_state = false
			return
		end

		local player = entity.get_local_player()
		if not player or not player:is_alive() then
			return
		end

		local target = nil
		local ok, t = pcall(entity.get_threat)
		if ok and t then target = t end
		if not target then
			ok, t = pcall(rage.antiaim.get_target, rage.antiaim)
			if ok and t then target = t end
		end
		if not target or not target:is_alive() or target:is_dormant() then
			force_shoot_runtime.peek_state = false
			return
		end

		local mode = fs.force_shoot_mode:get()
		local conditions = fs.force_shoot_condition:get()
		local should_shoot = false

		-- Check conditions
		local cond_visible = conditions["Enemy Visible"]
		local cond_not_dormant = conditions["Enemy Not Dormant"]
		local cond_dt_ready = conditions["DT Ready"]
		local cond_hs_ready = conditions["HS Ready"]
		local cond_in_air = conditions["In Air"]

		if cond_visible and not target:is_visible() then
			force_shoot_runtime.peek_state = false
			return
		end
		if cond_not_dormant and target:is_dormant() then
			return
		end

		local dt_ready = false
		local hs_ready = false
		pcall(function()
			dt_ready = bs_config.rage.main.double_tap:get() and rage.exploit:get() == 1
		end)
		pcall(function()
			hs_ready = bs_config.rage.main.hide_shots:get()
		end)

		if cond_dt_ready and not dt_ready then return end
		if cond_hs_ready and not hs_ready then return end

		local target_air = false
		pcall(function()
			target_air = bit.band(target.m_fFlags or 0, 1) == 0
		end)
		if cond_in_air and not target_air then return end

		-- Mode checks
		if mode == "Always" then
			should_shoot = true
		elseif mode == "On DT Charged" then
			should_shoot = dt_ready
		elseif mode == "On Peek (Visible)" then
			local was_visible = force_shoot_runtime.peek_state
			local now_visible = target:is_visible()
			should_shoot = now_visible and not was_visible
			force_shoot_runtime.peek_state = now_visible
		elseif mode == "On Enemy Shot" then
			local enemy_tick = 0
			pcall(function()
				enemy_tick = target.m_nTickBase or 0
			end)
			local tick_diff = enemy_tick - force_shoot_runtime.last_enemy_shot_tick
			if tick_diff > 0 and tick_diff <= 5 then
				should_shoot = true
			end
			force_shoot_runtime.last_enemy_shot_tick = enemy_tick
		end

		if should_shoot then
			cmd.in_attack = true
			force_shoot_runtime.last_shot_tick = globals.tickcount
			
			-- Hitbox override for "On Enemy Shot" mode
			if mode == "On Enemy Shot" then
				local hitbox_mode = fs.force_shoot_hitbox:get()
				local hitbox_delay = fs.force_shoot_hitbox_delay:get() or 0
				
				if hitbox_mode ~= "Off" and cmd.tickcount >= (force_shoot_runtime.last_enemy_shot_tick + hitbox_delay) then
					local hitbox = 0
					if hitbox_mode == "Head + Neck" then
						hitbox = 1  -- Neck
					end
					
					cmd.aim_hitbox = hitbox
					cmd.force_hitbox = hitbox
					
					pcall(function()
						rage.override_hitbox(hitbox)
					end)
					
					pcall(function()
						local hb = bs_config.rage.selection.hitboxes
						if hb then
							hb:override({hitbox == 0 and "Head" or "Neck"})
						end
					end)
				end
			end
		end
	end)

	events.round_start(function()
		force_shoot_runtime.peek_state = false
		force_shoot_runtime.last_shot_tick = 0
		force_shoot_runtime.last_enemy_shot_tick = 0
	end)
	events.level_change(function()
		force_shoot_runtime.peek_state = false
		force_shoot_runtime.last_shot_tick = 0
		force_shoot_runtime.last_enemy_shot_tick = 0
	end)
end




events.render:set(function()
  if not globals.is_connected or not globals.is_in_game then return end
  if not (bs_v777 and bs_v777.enabled and bs_v777.enabled:get()) then return end
  if not (bs_v777.esp and bs_v777.esp:get()) then return end
  local me = entity.get_local_player()
  if not me or not me:is_alive() then return end
  local threat = entity.get_threat()
  if not threat or not threat:is_alive() then return end
  local d = math.floor(me:get_origin():dist(threat:get_origin()))
  render.text(1, vector(render.screen_size().x * 0.5, render.screen_size().y * 0.5 + 30), color(255,255,255,255), "c", "DIST: " .. d .. " u")
end)
