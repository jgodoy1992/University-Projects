$(document).ready(function(){
    $(window).scroll(function(){
        if($(window).scrollTop() > 50){
            $('#nav-top').addClass('fixed-top');
            var navbarHeight = $('.navbar').outerHeight();
            $('body').css('padding-top', navbarHeight + 'px');
        } else {
            $('#nav-top').removeClass('fixed-top');
            $('body').css('padding-top', 0);
        }
    });
});


