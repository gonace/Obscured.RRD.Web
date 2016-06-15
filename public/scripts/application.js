/*!
 * JavaScript for Bootstrap's docs (http://getbootstrap.com)
 * Copyright 2011-2016 Twitter, Inc.
 * Licensed under the Creative Commons Attribution 3.0 Unported License. For
 * details, see https://creativecommons.org/licenses/by/3.0/.
 */

/* global ZeroClipboard, anchors */

!function ($) {
    'use strict';

    $(function () {
        // Scrollspy
        var $window = $(window);
        var $body   = $(document.body);

        $body.scrollspy({
            target: '.bs-docs-sidebar'
        });
        $window.on('load', function () {
            $body.scrollspy('refresh')
        });

        // Kill links
        $('.bs-docs-container .bs-docs-sidenav a[href="#"]').click(function (e) {
            e.preventDefault()
        });

        // Sidenav affixing
        setTimeout(function () {
            var $sideBar = $('.bs-docs-sidebar');

            $sideBar.affix({
                offset: {
                    top: function () {
                        var offsetTop      = $sideBar.offset().top;
                        var sideBarMargin  = parseInt($sideBar.children(0).css('margin-top'), 10);
                        var navOuterHeight = $('.bs-docs-nav').height();

                        return (this.top = offsetTop - navOuterHeight - sideBarMargin)
                    },
                    bottom: function () {
                        return (this.bottom = $('.bs-docs-footer').outerHeight(true))
                    }
                }
            })
        }, 100);

        setTimeout(function () {
            $('.bs-top').affix()
        }, 100);

        //Clipboard
        new Clipboard('*[data-copy="true"]');

        //Tooltip
        $(function () {
            $('[data-toggle="tooltip"]').tooltip()
        });
    })
}(jQuery.noConflict());

(function () {
    'use strict';
    anchors.options.placement = 'left';
    anchors.add('.bs-docs-section > h1, .bs-docs-section > h2, .bs-docs-section > h3, .bs-docs-section > h4, .bs-docs-section > h5')
})();