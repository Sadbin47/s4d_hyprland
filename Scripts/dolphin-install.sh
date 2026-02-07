#!/bin/bash
#=============================================================================
# DOLPHIN FILE MANAGER INSTALLATION
#=============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

log "${INFO} Installing Dolphin file manager..."

DOLPHIN_PACKAGES=(
    "dolphin"
    "ark"                     # Archive manager
    "kde-cli-tools"           # KDE utilities
    "ffmpegthumbs"            # Video thumbnails
    "kdegraphics-thumbnailers" # Image thumbnails
    "qt5-imageformats"        # Image format support
    "kimageformats5"          # Additional image formats
    "kio-extras"              # Extra KIO plugins
)

for pkg in "${DOLPHIN_PACKAGES[@]}"; do
    install_pkg "$pkg"
done

# Only create minimal Dolphin config if none exists
# This respects any existing dotfiles configuration
mkdir -p "$HOME/.config"

if [[ ! -f "$HOME/.config/dolphinrc" ]]; then
    log "${INFO} Creating clean Dolphin config..."

    cat > "$HOME/.config/dolphinrc" << 'EOF'
MenuBar=Disabled

[$Version]
update_info=dolphin_detailsmodesettings.upd:rename-leading-padding

[General]
BrowseThroughArchives=true
ConfirmClosingMultipleTabs=true
GlobalViewProps=true
RememberOpenedTabs=true
ShowFullPath=true
ShowFullPathInTitlebar=true
ShowSelectionToggle=false
ShowStatusBar=false
ShowZoomSlider=false
Version=202

[MainWindow]
MenuBar=Disabled
ToolBarsMovable=Disabled

[MainWindow][Toolbar mainToolBar]
IconSize=16
ToolButtonStyle=IconOnly

[PlacesPanel]
IconSize=16

[PreviewSettings]
Plugins=appimagethumbnail,audiothumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,opendocumentthumbnail,svgthumbnail,ffmpegthumbs

[DetailsMode]
ExpandableFolders=false
PreviewSize=22

[CompactMode]
PreviewSize=32

[IconsMode]
MaximumTextLines=1
PreviewSize=112

[InformationPanel]
dateFormat=ShortFormat

[Search]
Location=Everywhere

[VersionControl]
enabledPlugins=Git

[Toolbar mainToolBar]
ToolButtonStyle=IconOnly
EOF

    # Dolphin state
    cat > "$HOME/.config/dolphinstaterc" << 'EOF'
[State]
firstRun=false
EOF

    # Dolphin UI toolbar layout — clean minimal toolbar
    mkdir -p "$HOME/.local/share/kxmlgui5/dolphin"
    cat > "$HOME/.local/share/kxmlgui5/dolphin/dolphinui.rc" << 'XMLEOF'
<!DOCTYPE gui>
<gui name="dolphin" translationDomain="kxmlgui6" version="40">
 <MenuBar alreadyVisited="1">
  <Menu alreadyVisited="1" name="file" noMerge="1">
   <text translationDomain="kxmlgui6">&amp;File</text>
   <Action name="file_new"/>
   <Separator weakSeparator="1"/>
   <Action name="new_menu"/>
   <Action name="file_new"/>
   <Action name="new_tab"/>
   <Action name="file_close"/>
   <Action name="undo_close_tab"/>
   <Separator/>
   <Action name="add_to_places"/>
   <Separator/>
   <Action name="renamefile"/>
   <Action name="duplicate"/>
   <Action name="movetotrash"/>
   <Action name="deletefile"/>
   <Separator/>
   <Action name="show_target"/>
   <Separator/>
   <Action name="properties"/>
   <Separator weakSeparator="1"/>
   <Action name="file_close"/>
   <Separator weakSeparator="1"/>
   <Action name="file_quit"/>
  </Menu>
  <Menu alreadyVisited="1" name="edit" noMerge="1">
   <text translationDomain="kxmlgui6">&amp;Edit</text>
   <Action name="edit_undo"/>
   <Separator weakSeparator="1"/>
   <Action name="edit_cut"/>
   <Action name="edit_copy"/>
   <Action name="edit_paste"/>
   <Separator weakSeparator="1"/>
   <Action name="edit_select_all"/>
   <Separator weakSeparator="1"/>
   <Action name="edit_find"/>
   <Separator weakSeparator="1"/>
   <Action name="edit_undo"/>
   <Separator/>
   <Action name="edit_cut"/>
   <Action name="edit_copy"/>
   <Action name="copy_location"/>
   <Action name="edit_paste"/>
   <Separator/>
   <Action name="show_filter_bar"/>
   <Action name="edit_find"/>
   <Separator/>
   <Action name="toggle_selection_mode"/>
   <Action name="copy_to_inactive_split_view"/>
   <Action name="move_to_inactive_split_view"/>
   <Action name="edit_select_all"/>
   <Action name="invert_selection"/>
  </Menu>
  <Menu alreadyVisited="1" name="view" noMerge="1">
   <text translationDomain="kxmlgui6">&amp;View</text>
   <Action name="view_zoom_in"/>
   <Action name="view_zoom_out"/>
   <Separator weakSeparator="1"/>
   <Action name="view_redisplay"/>
   <Separator weakSeparator="1"/>
   <Action name="view_zoom_in"/>
   <Action name="view_zoom_reset"/>
   <Action name="view_zoom_out"/>
   <Separator/>
   <Action name="sort"/>
   <Action name="view_mode"/>
   <Action name="additional_info"/>
   <Action name="show_preview"/>
   <Action name="show_in_groups"/>
   <Action name="show_hidden_files"/>
   <Action name="act_as_admin"/>
   <Separator/>
   <Action name="split_view_menu"/>
   <Action name="popout_split_view"/>
   <Action name="split_stash"/>
   <Action name="redisplay"/>
   <Action name="stop"/>
   <Separator/>
   <Action name="panels"/>
   <Menu icon="edit-select-text" name="location_bar" noMerge="1">
    <text context="@title:menu" translationDomain="dolphin">Location Bar</text>
    <Action name="editable_location"/>
    <Action name="replace_location"/>
   </Menu>
   <Separator/>
   <Action name="view_properties"/>
  </Menu>
  <Menu alreadyVisited="1" name="go" noMerge="1">
   <text translationDomain="kxmlgui6">&amp;Go</text>
   <Action name="go_up"/>
   <Action name="go_back"/>
   <Action name="go_forward"/>
   <Action name="go_home"/>
   <Separator weakSeparator="1"/>
   <Action name="bookmarks"/>
   <Action name="closed_tabs"/>
  </Menu>
  <Menu alreadyVisited="1" name="tools" noMerge="1">
   <text translationDomain="kxmlgui6">&amp;Tools</text>
   <Action name="open_preferred_search_tool"/>
   <Action name="open_terminal"/>
   <Action name="open_terminal_here"/>
   <Action name="focus_terminal_panel"/>
   <Action name="compare_files"/>
   <Action name="change_remote_encoding"/>
  </Menu>
  <Menu name="settings" noMerge="1">
   <text translationDomain="kxmlgui6">&amp;Settings</text>
   <Action name="options_show_menubar"/>
   <Merge name="StandardToolBarMenuHandler"/>
   <Merge name="KMDIViewActions"/>
   <Action name="options_show_statusbar"/>
   <Separator weakSeparator="1"/>
   <Action name="switch_application_language"/>
   <Action name="options_configure_keybinding"/>
   <Action name="options_configure_toolbars"/>
   <Action name="options_configure"/>
  </Menu>
  <Separator weakSeparator="1"/>
  <Menu name="help" noMerge="1">
   <text translationDomain="kxmlgui6">&amp;Help</text>
   <Action name="help_contents"/>
   <Action name="help_whats_this"/>
   <Action name="open_kcommand_bar"/>
   <Separator weakSeparator="1"/>
   <Action name="help_report_bug"/>
   <Separator weakSeparator="1"/>
   <Action name="help_donate"/>
   <Separator weakSeparator="1"/>
   <Action name="help_about_app"/>
   <Action name="help_about_kde"/>
  </Menu>
 </MenuBar>
 <ToolBar alreadyVisited="1" name="mainToolBar" noMerge="1">
  <Spacer name="spacer_0"/>
  <Action name="invert_selection"/>
  <Action name="show_hidden_files"/>
  <Action name="create_dir"/>
  <text context="@title:menu" translationDomain="dolphin">Main Toolbar</text>
  <Action name="split_view"/>
  <Action name="hamburger_menu"/>
 </ToolBar>
 <State name="new_file">
  <disable>
   <Action name="edit_undo"/>
   <Action name="edit_redo"/>
   <Action name="edit_cut"/>
   <Action name="renamefile"/>
   <Action name="movetotrash"/>
   <Action name="deletefile"/>
   <Action name="invert_selection"/>
   <Separator/>
   <Action name="go_back"/>
   <Action name="go_forward"/>
  </disable>
 </State>
 <State name="has_selection">
  <enable>
   <Action name="invert_selection"/>
  </enable>
 </State>
 <State name="has_no_selection">
  <disable>
   <Action name="delete_shortcut"/>
   <Action name="invert_selection"/>
  </disable>
 </State>
 <ActionProperties scheme="Default">
  <Action name="compact" priority="0"/>
  <Action name="details" priority="0"/>
  <Action name="edit_copy" priority="0"/>
  <Action name="edit_cut" priority="0"/>
  <Action name="edit_paste" priority="0"/>
  <Action name="go_back" priority="0"/>
  <Action name="go_forward" priority="0"/>
  <Action name="go_home" priority="0"/>
  <Action name="go_up" priority="0"/>
  <Action name="icons" priority="0"/>
  <Action name="stop" priority="0"/>
  <Action name="toggle_filter" priority="0"/>
  <Action name="toggle_search" priority="0"/>
  <Action name="view_zoom_in" priority="0"/>
  <Action name="view_zoom_out" priority="0"/>
  <Action name="view_zoom_reset" priority="0"/>
 </ActionProperties>
</gui>
XMLEOF

    # Dolphin view properties
    mkdir -p "$HOME/.local/share/dolphin/view_properties/global"
    cat > "$HOME/.local/share/dolphin/view_properties/global/.directory" << 'EOF'
[Dolphin]
SortHiddenLast=true
Version=4
EOF

    # Disable Baloo file indexer (heavy, unnecessary on minimal setup)
    cat > "$HOME/.config/baloofilerc" << 'EOF'
[Basic Settings]
Indexing-Enabled=false
EOF

else
    log "${OK} Dolphin config already exists - preserving your dotfiles settings"
fi

log "${OK} Dolphin installed and configured"

