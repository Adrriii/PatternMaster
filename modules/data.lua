-- Inspired from https://github.com/Illuminati-CRAZ/Memory-2

prefix = "PatternMasterData"

function data.FindLayerThatStartsWith(str)
    for _, layer in pairs(map.EditorLayers) do
        if util.StartsWith(layer.Name, str) then
            return layer
        end
    end
end

function data.Save(name, value)
    name = prefix .. "|" .. name
    local data_layer = data.FindLayerThatStartsWith(name .. ":")

    if data_layer then
        actions.RenameLayer(data_layer, name .. ":" .. value)
    else
        data_layer = utils.CreateEditorLayer(name .. ":" .. value)
        actions.CreateLayer(data_layer)
    end
end

function data.Delete(name)
    name = prefix .. "|" .. name
    local data_layer = data.FindLayerThatStartsWith(name .. ":")

    if data_layer then
        actions.RemoveLayer(data_layer)
    end
end

function data.Load(name)
    name = prefix .. "|" .. name
    local data_layer = data.FindLayerThatStartsWith(name .. ":")

    if data_layer then
        return data_layer.Name:sub(#name + 2, #data_layer.Name)
    end
end

function data.LoadLayer(layer)
    return util.strsplit(layer,":")[2]
end

function data.GetVariableName(layer)
    if util.StartsWith(layer, prefix) then
        return util.strsplit(util.strsplit(layer,"|")[2],":")[1]
    end
end

function data.GetDataLayers()
    local layers = {}
    for _, layer in pairs(map.EditorLayers) do
        if util.StartsWith(layer.Name, prefix) then
            table.insert(layers, layer.Name)
        end
    end
    return layers
end