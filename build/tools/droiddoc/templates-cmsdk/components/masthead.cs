<?cs def:custom_masthead() ?>
  <div id="header">
      <div id="headerLeft">
          <a href="<?cs var:toroot ?>index.html" tabindex="-1"><img
              src="<?cs var:toroot ?>assets/cid_smart.png" alt="CID" width="30" height="30"/>
          <span id="masthead-title">CyanogenMod Platform SDK</span></a>
      </div>
      <div id="headerRight">
          <div id="search">
              <div id="searchForm">
                  <form accept-charset="utf-8" class="gsc-search-box" onsubmit="return submit_search()">
                    <table class="gsc-search-box" cellpadding="0" cellspacing="0"><tbody>
                        <tr>
                          <td class="gsc-input">
                            <input id="search_autocomplete" class="gsc-input" type="text" size="33" autocomplete="off" title="search developer docs" name="q" value="search developer docs" onfocus="search_focus_changed(this, true)" onblur="search_focus_changed(this, false)" onkeydown="return search_changed(event, true, '../../../../../../')" onkeyup="return search_changed(event, false, '../../../../../../')" style="color: rgb(170, 170, 170);">
                          <div id="search_filtered_div" class="no-display">
                              <table id="search_filtered" cellspacing="0">
                              </table>
                          </div>
                          </td>
                          <td class="gsc-search-button">
                            <input type="submit" value="Search" title="search" id="search-button" class="gsc-search-button">
                          </td>
                          <td class="gsc-clear-button">
                            <div title="clear results" class="gsc-clear-button">&nbsp;</div>
                          </td>
                        </tr></tbody>
                      </table>
                  </form>
              </div><!-- searchForm -->
          </div><!-- search -->
      </div><!-- headerRight -->
  </div><!-- header --><?cs 
/def ?>

