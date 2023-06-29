local Component = require("lib.widgey.Component")

local CommentComponent = Component:extend("CommentComponent", "__comment")

CommentComponent.default_props = {
    comment = ""
}

function CommentComponent:render()
    if self:is_static() then
        return self:lua("-- self.props.comment")
    else
        return nil
    end
end

return CommentComponent
