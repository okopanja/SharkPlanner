local background_color = "0xffffffff"
local font_color = background_color
local skin = {
	["skinData"] = {
		["params"] = {
		},
		["states"] = {
			["disabled"] = {
				[1] = {
					["bkg"] = {
						["center_bottom"] = background_color,
						["center_center"] = background_color,
						["center_top"] = background_color,
						["file"] = "Scripts\\SharkPlanner\\UI\\images\\line_waypoint_dotted.png",
						["insets"] = {
							["bottom"] = 0,
							["left"] = 0,
							["right"] = 0,
							["top"] = 0,
						},
						["left_bottom"] = background_color,
						["left_center"] = background_color,
						["left_top"] = background_color,
						["rect"] = {
							["x1"] = 0,
							["x2"] = 0,
							["y1"] = 0,
							["y2"] = 0,
						},
						["right_bottom"] = background_color,
						["right_center"] = background_color,
						["right_top"] = background_color,
					},
					["text"] = {
						["blur"] = 0,
						["color"] = font_color,
						["font"] = "DejaVuLGCSansCondensed-Bold.ttf",
						["fontSize"] = 12,
						["horzAlign"] = {
							["type"] = "min",
						},
						["shadowOffset"] = {
							["horz"] = 0,
							["vert"] = 0,
						},
						["vertAlign"] = {
							["offset"] = 0,
							["type"] = "middle",
						},
					},
				},
			},
			["released"] = {
				[1] = {
					["bkg"] = {
						["center_bottom"] = background_color,
						["center_center"] = background_color,
						["center_top"] = background_color,
						["file"] = "Scripts\\SharkPlanner\\UI\\images\\line_waypoint_right_dotted.png",
						["insets"] = {
							["bottom"] = 0,
							["left"] = 0,
							["right"] = 0,
							["top"] = 0,
						},
						["left_bottom"] = background_color,
						["left_center"] = background_color,
						["left_top"] = background_color,
						["rect"] = {
							["x1"] = 1,
							["y1"] = 0,
							["x2"] = 0,
							["y2"] = 45,
						},
						["right_bottom"] = background_color,
						["right_center"] = background_color,
						["right_top"] = background_color,
					},
					["text"] = {
						["blur"] = 0,
						["color"] = font_color,
						["font"] = "DejaVuLGCSansCondensed-Bold.ttf",
						["fontSize"] = 12,
						["horzAlign"] = {
							["offset"] = -5,
							["type"] = "max",
						},
						["shadowColor"] = "0x000000ff",
						["shadowOffset"] = {
							["horz"] = 1,
							["vert"] = 1,
						},
						["vertAlign"] = {
							["offset"] = 0,
							["type"] = "min",
						},
					},
				},
			},
		},
		["type"] = "Static",
	},
	["version"] = 1,
}

return skin