(function($) {
    $(function() {
        var avaliableColumns = '#available_columns';
        var selectedColumns = '#selected_columns';
        var queryForm = '#query_form';
        var main = $('#main');

        main.on('click', queryForm + ' .add', function() {
            moveOptions(avaliableColumns, selectedColumns);
        });
        main.on('click', queryForm + ' .remove', function() {
            moveOptions(selectedColumns, avaliableColumns);
        });

        main.on('click', queryForm + ' .up', function() {
            changeOptionPosition(selectedColumns, 0);
        });
        main.on('click', queryForm + ' .down', function() {
            changeOptionPosition(selectedColumns, 1);
        });

        main.on('click', queryForm + ' .apply', function(e) {
            e.preventDefault();
            selectAllOptions(selectedColumns);

            var data = $(queryForm).serializeArray();
            var url = jQuery('form[action*="issues"]').attr('action');
            $.ajax({
                url: url + '?set_filter=1',
                data: data,
                type: 'GET',
                dataType: 'html',
                success: function(response) {
                    $('#content').html(response);
                    apply_filters_observer();
                }
            });
        });

        function moveOptions(theSelFrom, theSelTo) {
            theSelFrom = $(theSelFrom);
            theSelTo = $(theSelTo);
            selectedOptions = theSelFrom.find('option:selected');
            selectedOptions.appendTo(theSelTo).attr('selected', false);
        }

        function changeOptionPosition(theSelForm, direction) {
            theSelForm = $(theSelForm);
            var selectedItems = theSelForm.find('option:selected');
            if(direction === 1) {
                selectedItems = $(selectedItems.get().reverse());
            }

            selectedItems.each(function() {
                var self = $(this);
                if(direction === 0) {
                    if(self.prev('option').is(':selected') === false) {
                        self.prev('option').before(self);
                    }
                } else {
                    if(self.next('option').is(':selected') === false) {
                        self.next('option').after(self);
                    }
                }
            });
        }

        function selectAllOptions(id) {
            $(id + ' option').attr('selected', true);
        }
    });
})(jQuery);
