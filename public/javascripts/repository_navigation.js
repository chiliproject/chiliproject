(function($) {
    $(document).ready(function() {
        var branchSelect = $('#branch');
        var tagSelect = $('#tag');
        var branchAndTag = branchSelect.add(tagSelect);
        var revInput = $('#rev');
        var isBranchSelected = branchSelect && revInput.val() === branchSelect.val();
        var isTagSelected = tagSelect && revInput.val() === tagSelect.val();

        // If we're viewing a tag or branch, don't display it in the revision
        // box
        if (isBranchSelected || isTagSelected) {
            revInput.val('');
        }

        // Copy the branch/tag value into the revision box, then disable the 
        // dropdowns before submitting the form
        branchAndTag.on('change', function() {
            var self = $(this);
            revInput.val(self.val());
            branchAndTag.attr('disabled', 'disabled');
            self.parents('form').submit();
        });

        // Submit the form when the enter key is pressed in the revision box
        // after disabling the select boxes
        revInput.on('keydown', function(e) {
            var self = $(this);
            if(e.keyCode === 13) {
                branchAndTag.attr('disabled', 'disabled');
                self.parents('form').submit();
            }
        });
    });
})(jQuery);

