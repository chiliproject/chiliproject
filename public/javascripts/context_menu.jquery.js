(function($) {
    var observingContextMenuClick;
    var url;
    var lastSelected;
    var menu;
    var menuId = 'context-menu';
    var selectorName = 'hascontextmenu';
    var contextMenuSelectionClass = 'context-menu-selection';

    var methods = {
        createMenu: function() {
            if(!menu) {
                $('#wrapper').append('<div id="' + menuId + '" style="display:none"></div>');
                menu = $('#' + menuId);
            }
        },
        Click: function(e) {
            methods.hideMenu();
            var target = $(e.target);

            if(target.is('a')) {
                return;
            }

            switch(e.which) {
                case 1:
                    if(e.type === 'click') {
                        methods.LeftClick(e);
                        break;
                    }
                case 3:
                    if(e.type === 'contextmenu') {
                        methods.RightClick(e);
                        break;
                    }
                default:
                    return;
            }
        },
        LeftClick: function(e) {
            var target = $(e.target);
            var tr = target.parents('tr');
            if((tr.size() > 0) && tr.hasClass(selectorName))
            {
                // a row was clicked, check if the click was on checkbox
                if(target.is('input'))
                {
                    // a checkbox may be clicked
                    if (target.is(':checked')) {
                        tr.addClass(contextMenuSelectionClass);
                    } else {
                        tr.removeClass(contextMenuSelectionClass);
                    }
                }
                else
                {
                    if (e.ctrlKey || e.metaKey)
                    {
                        methods.toggleSelection(tr);
                    }
                    else if (e.shiftKey)
                    {
                        if (lastSelected !== null)
                        {
                            var toggling = false;
                            var rows = $(selectorName);
                            for (i = 0; i < rows.length; i++)
                            {
                                if (toggling || rows[i] == tr)
                                {
                                    methods.addSelection(rows[i]);
                                }
                                if (rows[i] == tr || rows[i] == lastSelected)
                                {
                                    toggling = !toggling;
                                }
                            }
                        } else {
                            methods.addSelection(tr);
                        }
                    } else {
                        methods.unselectAll();
                        methods.addSelection(tr);
                    }
                    lastSelected = tr;
                }
            }
            else
            {
                // click is outside the rows
                if (target.is('a') === false) {
                    this.unselectAll();
                } else {
                    if (target.hasClass('disabled') || target.hasClass('submenu')) {
                        e.preventDefault();
                    }
                }
            }
        },
        RightClick: function(e) {
            var target = $(e.target);
            var tr = target.parents('tr');

            if((tr.size() === 0) || !(tr.hasClass(selectorName))) {
                return;
            }
            e.preventDefault();

            if(!methods.isSelected(tr)) {
                methods.unselectAll();
                methods.addSelection(tr);
                lastSelected = tr;
            }
            methods.showMenu(e);
        },
        unselectAll: function() {
            var rows = $('.' + contextMenuSelectionClass);
            rows.each(function() {
                methods.removeSelection($(this));
            });
        },
        hideMenu: function() {
           menu.hide();
        },
        showMenu: function(e) {
            //menu.show();
            var target = $(e.target);
            var params = target.parents('form').serialize();

            var mouseX = e.pageX;
            var mouseY = e.pageY;

            $.ajax({
                url: url,
                data: params,
                success: function(response, success) {
                    menu.html(response);
                    menu.css('top', mouseY).css('left', mouseX);
                    menu.show();
                }
            });
        },
        addSelection: function(element) {
           element.addClass(contextMenuSelectionClass);
           methods.checkSelectionBox(element, true);
        },
        isSelected: function(element) {
            return element.hasClass(contextMenuSelectionClass);
        },
        toggleSelection: function(element) {
            if(methods.isSelected(element)) {
                methods.removeSelection(element);
            } else {
                methods.addSelection(element);
            }
        },
        removeSelection: function(element) {
            element.removeClass(contextMenuSelectionClass);
            methods.checkSelectionBox(element, false);
        },
        checkSelectionBox: function(element, checked) {
            var inputs = element.find('input');
            inputs.each(function() {
                inputs.attr('checked', checked ? 'checked' : false);
            });
        }
    };

    $.fn.contextMenu = function(u) {
        url = u;
        methods.createMenu();

        if(!observingContextMenuClick) {
            $(document).bind('click.contextMenu', methods.Click);
            $(document).bind('contextmenu.contextMenu', methods.Click);
            observingContextMenuClick = true;
        }

        methods.unselectAll();
        lastSelected = null;
    };
})(jQuery);
