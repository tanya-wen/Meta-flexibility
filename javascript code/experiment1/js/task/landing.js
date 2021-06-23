/**
 * Instructions / landing
 *
 *   
 *
 **/

const landing = function () {
    let current = -1;

    let init = function () {
        eventTimer.cancelAllRequests();
        current_task = "landing"

        // hide load screen if visible
        if(document.querySelector("#load-display")){document.querySelector("#load-display").style.display = "none"}

        // create content display within the main-display div
        document.querySelector("#main-display").style.display = "flex"
        document.querySelector("#main-display").innerHTML = '<div class="content-display flex flex-column justify-center lh-copy" style="text-align: left"></div>'

        // 
        next();
    }
    const page = [
        function p_1() {
            document.querySelector("#main-display").style.display = "flex"
            document.querySelector("#main-display").innerHTML = [
        '<div class="content-display flex flex-column justify-center lh-copy" style="text-align: left">',
            '<h3>Welcome to the experiment!</h3>',
            '<div >',
            '<p>Thank you for agreeing to participate in this research. </p>',
            '<p>The experiment will need to run in fullscreen mode. When you hit "NEXT" the screen will change to fullscreen. Please keep it in fullscreen until the end of the experiment.</p>',
            '<p>When you are ready to begin the first part press the "NEXT" button </p>',
            '<p style="color:red"><em>It may take up to 2 minutes to load the experiment. Please be patient while it is loading. </em></p>',
            '</div>',
            '<a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-dark-gray data-toggle-fullscreen" style="width: 200px; text-align: center; " href="#0">NEXT</a>',
        '</div>'
    ].join("\n")

            document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: landing.next(); screenfull.toggle();")
    }
]

    function next() {
        current++
        if (current < landing.page.length) {
            landing.page[current]();
        } else {
            master.next();
        }

    }

    function previous() {
        current--
        landing.page[current]();
    }


    return {
        init: init,
        page: page,
        next: next,
        previous: previous
    }
}();
