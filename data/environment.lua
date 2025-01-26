local tree = {}

local treeData = {
	{ x=340, y=320 },
	{ x=480, y=320 },
	{ x=620, y=320 },
}

local function createTree( x, y )
	local tree = display.newImageRect("assets/Puu.PNG",x, y, 64, 64 )
	return tree
end

for i = 1, #treeData do
    tree[i] = createTree( treeData[i].x, treeData[i].y )
end
