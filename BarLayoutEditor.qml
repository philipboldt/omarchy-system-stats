import QtQuick
import QtQuick.Controls as Controls
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

Item {
  id: editor

  required property var layout
  required property var strings
  required property color foreground
  required property string fontFamily
  required property bool panelOpen

  property var plugins: []
  property var source: null
  property real pointerY: -1
  property bool scanFailed: false
  property bool moveFailed: false
  property bool scanPending: false

  readonly property var sections: ["left", "centerBegin", "center", "centerEnd", "right", "tray"]
  readonly property real rowHeight: Style.space(34)
  readonly property int targetIndex: source && pointerY >= 0 && pointerY < list.height
    ? Math.floor((pointerY + list.contentY - list.originY) / rowHeight) : -1
  readonly property var rows: {
    var result = []
    var installed = Object.create(null)
    var placed = Object.create(null)
    for (var plugin of plugins) installed[plugin.id] = plugin

    for (var section of sections) {
      result.push({ title: strings.t("layout." + section), section: section })
      var entries = layout[section] || []
      for (var index = 0; index < entries.length; index++) {
        var entry = entries[index]
        var id = typeof entry === "string" ? entry : entry.id
        if (typeof id !== "string" || !id) continue
        placed[id] = true
        var metadata = installed[id]
        result.push({ id: id, title: metadata ? metadata.name : id, section: section, index: index })
      }
    }

    var unplaced = plugins.filter(function(plugin) { return !placed[plugin.id] })
    if (unplaced.length) {
      result.push({ title: strings.t("layout.otherPlugins") })
      for (var plugin of unplaced)
        result.push({ id: plugin.id, title: plugin.name })
    }
    return result
  }

  function scan() {
    if (!panelOpen) return
    if (inventory.running) {
      scanPending = true
      return
    }
    scanFailed = false
    inventory.running = true
  }

  function drop() {
    var dragged = source
    var target = rows[targetIndex]
    var after = (pointerY + list.contentY - list.originY) % rowHeight >= rowHeight / 2
    cancelDrag()
    if (!target || !target.section || !dragged || dragged === target || move.running) return

    var command = ["omarchy", "bar", "move", dragged.id,
      "--from-section", dragged.section, "--from-index", String(dragged.index)]
    if (target.id && target.id !== dragged.id) {
      command.push(after ? "--after" : "--before", target.id)
    } else if (!target.id || target.section !== dragged.section) {
      command.push("--section", target.section, "--index", String(target.id ? target.index + (after ? 1 : 0) : 0))
    } else {
      return
    }
    moveFailed = false
    move.command = command
    move.running = true
  }

  function cancelDrag() {
    source = null
    pointerY = -1
  }

  Component.onCompleted: {
    if (panelOpen) Qt.callLater(scan)
  }
  onPanelOpenChanged: {
    if (panelOpen) Qt.callLater(scan)
  }
  onVisibleChanged: {
    if (visible) Qt.callLater(scan)
    else cancelDrag()
  }

  Process {
    id: inventory
    command: ["omarchy", "plugin", "list", "--json"]
    stdout: StdioCollector {}
    onExited: function(code) {
      try {
        if (code !== 0 || stdout.text.length > 524288) throw new Error()
        var entries = JSON.parse(stdout.text)
        if (!Array.isArray(entries)) throw new Error()
        editor.plugins = entries.slice(0, 1024).filter(function(entry) {
          return entry && typeof entry.id === "string"
        }).map(function(entry) {
          return { id: entry.id, name: Model.cleanDisplayText(entry.name, 128) || entry.id }
        })
      } catch (error) {
        editor.scanFailed = true
      }
      if (editor.scanPending) {
        editor.scanPending = false
        Qt.callLater(editor.scan)
      }
    }
  }

  Process {
    id: move
    onExited: function(code) { editor.moveFailed = code !== 0 }
  }

  Text {
    id: hint
    width: parent.width
    textFormat: Text.PlainText
    text: editor.strings.t(editor.moveFailed ? "layout.moveFailed" : editor.scanFailed ? "layout.scanFailed" : "layout.hint")
    wrapMode: Text.WordWrap
    color: editor.foreground
    font.family: editor.fontFamily
    font.pixelSize: Style.font.caption
  }

  Flickable {
    id: list
    anchors.top: hint.bottom
    anchors.topMargin: Style.space(8)
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    contentWidth: width
    contentHeight: rowsColumn.height
    Controls.ScrollBar.vertical: Controls.ScrollBar {}

    Column {
      id: rowsColumn
      width: list.width

      Repeater {
        model: editor.rows
        delegate: Rectangle {
          id: row
          required property int index
          required property var modelData
          readonly property bool movable: !!modelData.id && !!modelData.section
          readonly property bool target: index === editor.targetIndex && !!modelData.section

          width: list.width - Style.space(12)
          height: editor.rowHeight
          radius: Style.cornerRadius
          color: modelData.id ? Qt.rgba(editor.foreground.r, editor.foreground.g, editor.foreground.b, target ? 0.16 : 0.06) : "transparent"
          border.color: target ? Commons.Color.accent : "transparent"
          opacity: editor.source === modelData ? 0.55 : 1

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Style.space(8)
            textFormat: Text.PlainText
            elide: Text.ElideRight
            text: (row.movable ? "󰇙  " : row.modelData.id ? "     " : "") + row.modelData.title
            color: row.modelData.id && !row.movable ? Qt.darker(editor.foreground, 1.4) : editor.foreground
            font.family: editor.fontFamily
            font.pixelSize: row.modelData.id ? Style.font.bodySmall : Style.font.caption
            font.bold: !row.modelData.id
          }

          MouseArea {
            anchors.fill: parent
            enabled: row.movable && !move.running
            preventStealing: true
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            onPressed: function(mouse) {
              editor.source = row.modelData
              editor.pointerY = mapToItem(list, mouse.x, mouse.y).y
            }
            onPositionChanged: function(mouse) {
              if (pressed) editor.pointerY = mapToItem(list, mouse.x, mouse.y).y
            }
            onReleased: editor.drop()
            onCanceled: editor.cancelDrag()
          }
        }
      }
    }
  }

  Timer {
    interval: 32
    repeat: true
    running: editor.source !== null
    onTriggered: {
      var edge = editor.rowHeight
      if (editor.pointerY < edge) list.contentY = Math.max(list.originY, list.contentY - Style.space(8))
      else if (editor.pointerY > list.height - edge)
        list.contentY = Math.min(list.originY + Math.max(0, list.contentHeight - list.height), list.contentY + Style.space(8))
    }
  }
}
