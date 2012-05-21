(function($) {
    $(document).ready(function() {
        var moveButtons = $('.query-columns .buttons.move');
        var positionButtons = $('.query-columns .buttons.position');

        var avaliableColumns = $('#available_columns');
        var selectedColumns = $('#selected_columns');

        moveButtons.find('.add').on('click', function() {
            moveOptions(avaliableColumns, selectedColumns);
        });
        moveButtons.find('.remove').on('click', function() {
            moveOptions(selectedColumns, avaliableColumns);
        });

        positionButtons.find('.up').on('click', function() {
            changeOptionPosition(selectedColumns, 0);
        });
        positionButtons.find('.down').on('click', function() {
            changeOptionPosition(selectedColumns, 1);
        });

        function moveOptions(theSelFrom, theSelTo) {
            selectedOptions = theSelFrom.find('option:selected');
            selectedOptions.appendTo(theSelTo);
        }

        function changeOptionPosition(theSelForm, direction) {
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
    });
})(jQuery);
