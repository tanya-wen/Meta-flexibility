/***

Wisconsin Card Sorting Task w/ shapes & multiple task-sets

***/
// fallback to vanilla timers if eventTimer is not loaded...
if (typeof eventTimer == 'undefined') {
    //console.log("no eventTimer found... using JS setTimeout/Interval")
    var eventTimer = {};
    eventTimer.setTimeout = function (fun, time) {
        window.setTimeout(fun, time)
    }
    eventTimer.setInterval = function (fun, time) {
        window.setInterval(fun, time)
    }
}

// preload images & run instructions_pg1 when complete
preLoad.addImages(["images/MainExpStimuli/shapes/Blue_Circle_Chess_1.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Chess_2.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Chess_3.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Chess_4.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Dots_1.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Dots_2.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Dots_3.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Dots_4.jpg",
    "images/MainExpStimuli/shapes/Blue_Circle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Stripes_3.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Grid_1.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Grid_2.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Grid_3.jpg", "images/MainExpStimuli/shapes/Blue_Circle_Grid_4.jpg",
    "images/MainExpStimuli/shapes/Blue_Triangle_Chess_1.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Chess_2.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Chess_3.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Chess_4.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Dots_1.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Dots_2.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Dots_3.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Dots_4.jpg",
    "images/MainExpStimuli/shapes/Blue_Triangle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Stripes_3.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Grid_1.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Grid_2.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Grid_3.jpg", "images/MainExpStimuli/shapes/Blue_Triangle_Grid_4.jpg",
    "images/MainExpStimuli/shapes/Blue_Plus_Chess_1.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Chess_2.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Chess_3.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Chess_4.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Dots_1.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Dots_2.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Dots_3.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Dots_4.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Stripes_1.jpg",
    "images/MainExpStimuli/shapes/Blue_Plus_Stripes_2.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Stripes_3.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Stripes_4.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Grid_1.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Grid_2.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Grid_3.jpg", "images/MainExpStimuli/shapes/Blue_Plus_Grid_4.jpg", "images/MainExpStimuli/shapes/Blue_Star_Chess_1.jpg", "images/MainExpStimuli/shapes/Blue_Star_Chess_2.jpg",
    "images/MainExpStimuli/shapes/Blue_Star_Chess_3.jpg", "images/MainExpStimuli/shapes/Blue_Star_Chess_4.jpg", "images/MainExpStimuli/shapes/Blue_Star_Dots_1.jpg", "images/MainExpStimuli/shapes/Blue_Star_Dots_2.jpg", "images/MainExpStimuli/shapes/Blue_Star_Dots_3.jpg", "images/MainExpStimuli/shapes/Blue_Star_Dots_4.jpg", "images/MainExpStimuli/shapes/Blue_Star_Stripes_1.jpg", "images/MainExpStimuli/shapes/Blue_Star_Stripes_2.jpg", "images/MainExpStimuli/shapes/Blue_Star_Stripes_3.jpg",
    "images/MainExpStimuli/shapes/Blue_Star_Stripes_4.jpg", "images/MainExpStimuli/shapes/Blue_Star_Grid_1.jpg", "images/MainExpStimuli/shapes/Blue_Star_Grid_2.jpg", "images/MainExpStimuli/shapes/Blue_Star_Grid_3.jpg", "images/MainExpStimuli/shapes/Blue_Star_Grid_4.jpg", "images/MainExpStimuli/shapes/Green_Circle_Chess_1.jpg", "images/MainExpStimuli/shapes/Green_Circle_Chess_2.jpg", "images/MainExpStimuli/shapes/Green_Circle_Chess_3.jpg",
    "images/MainExpStimuli/shapes/Green_Circle_Chess_4.jpg", "images/MainExpStimuli/shapes/Green_Circle_Dots_1.jpg", "images/MainExpStimuli/shapes/Green_Circle_Dots_2.jpg", "images/MainExpStimuli/shapes/Green_Circle_Dots_3.jpg", "images/MainExpStimuli/shapes/Green_Circle_Dots_4.jpg", "images/MainExpStimuli/shapes/Green_Circle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Green_Circle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Green_Circle_Stripes_3.jpg",
    "images/MainExpStimuli/shapes/Green_Circle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Green_Circle_Grid_1.jpg", "images/MainExpStimuli/shapes/Green_Circle_Grid_2.jpg", "images/MainExpStimuli/shapes/Green_Circle_Grid_3.jpg", "images/MainExpStimuli/shapes/Green_Circle_Grid_4.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Chess_1.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Chess_2.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Chess_3.jpg",
    "images/MainExpStimuli/shapes/Green_Triangle_Chess_4.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Dots_1.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Dots_2.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Dots_3.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Dots_4.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Stripes_3.jpg",
    "images/MainExpStimuli/shapes/Green_Triangle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Grid_1.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Grid_2.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Grid_3.jpg", "images/MainExpStimuli/shapes/Green_Triangle_Grid_4.jpg", "images/MainExpStimuli/shapes/Green_Plus_Chess_1.jpg", "images/MainExpStimuli/shapes/Green_Plus_Chess_2.jpg", "images/MainExpStimuli/shapes/Green_Plus_Chess_3.jpg",
    "images/MainExpStimuli/shapes/Green_Plus_Chess_4.jpg", "images/MainExpStimuli/shapes/Green_Plus_Dots_1.jpg", "images/MainExpStimuli/shapes/Green_Plus_Dots_2.jpg", "images/MainExpStimuli/shapes/Green_Plus_Dots_3.jpg", "images/MainExpStimuli/shapes/Green_Plus_Dots_4.jpg", "images/MainExpStimuli/shapes/Green_Plus_Stripes_1.jpg", "images/MainExpStimuli/shapes/Green_Plus_Stripes_2.jpg", "images/MainExpStimuli/shapes/Green_Plus_Stripes_3.jpg",
    "images/MainExpStimuli/shapes/Green_Plus_Stripes_4.jpg", "images/MainExpStimuli/shapes/Green_Plus_Grid_1.jpg", "images/MainExpStimuli/shapes/Green_Plus_Grid_2.jpg", "images/MainExpStimuli/shapes/Green_Plus_Grid_3.jpg", "images/MainExpStimuli/shapes/Green_Plus_Grid_4.jpg", "images/MainExpStimuli/shapes/Green_Star_Chess_1.jpg", "images/MainExpStimuli/shapes/Green_Star_Chess_2.jpg", "images/MainExpStimuli/shapes/Green_Star_Chess_3.jpg",
    "images/MainExpStimuli/shapes/Green_Star_Chess_4.jpg", "images/MainExpStimuli/shapes/Green_Star_Dots_1.jpg", "images/MainExpStimuli/shapes/Green_Star_Dots_2.jpg", "images/MainExpStimuli/shapes/Green_Star_Dots_3.jpg", "images/MainExpStimuli/shapes/Green_Star_Dots_4.jpg", "images/MainExpStimuli/shapes/Green_Star_Stripes_1.jpg", "images/MainExpStimuli/shapes/Green_Star_Stripes_2.jpg", "images/MainExpStimuli/shapes/Green_Star_Stripes_3.jpg",
    "images/MainExpStimuli/shapes/Green_Star_Stripes_4.jpg", "images/MainExpStimuli/shapes/Green_Star_Grid_1.jpg", "images/MainExpStimuli/shapes/Green_Star_Grid_2.jpg", "images/MainExpStimuli/shapes/Green_Star_Grid_3.jpg", "images/MainExpStimuli/shapes/Green_Star_Grid_4.jpg", "images/MainExpStimuli/shapes/Red_Circle_Chess_1.jpg", "images/MainExpStimuli/shapes/Red_Circle_Chess_2.jpg", "images/MainExpStimuli/shapes/Red_Circle_Chess_3.jpg",
    "images/MainExpStimuli/shapes/Red_Circle_Chess_4.jpg", "images/MainExpStimuli/shapes/Red_Circle_Dots_1.jpg", "images/MainExpStimuli/shapes/Red_Circle_Dots_2.jpg", "images/MainExpStimuli/shapes/Red_Circle_Dots_3.jpg", "images/MainExpStimuli/shapes/Red_Circle_Dots_4.jpg", "images/MainExpStimuli/shapes/Red_Circle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Red_Circle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Red_Circle_Stripes_3.jpg",
    "images/MainExpStimuli/shapes/Red_Circle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Red_Circle_Grid_1.jpg", "images/MainExpStimuli/shapes/Red_Circle_Grid_2.jpg", "images/MainExpStimuli/shapes/Red_Circle_Grid_3.jpg", "images/MainExpStimuli/shapes/Red_Circle_Grid_4.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Chess_1.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Chess_2.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Chess_3.jpg",
    "images/MainExpStimuli/shapes/Red_Triangle_Chess_4.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Dots_1.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Dots_2.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Dots_3.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Dots_4.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Stripes_3.jpg",
    "images/MainExpStimuli/shapes/Red_Triangle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Grid_1.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Grid_2.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Grid_3.jpg", "images/MainExpStimuli/shapes/Red_Triangle_Grid_4.jpg", "images/MainExpStimuli/shapes/Red_Plus_Chess_1.jpg", "images/MainExpStimuli/shapes/Red_Plus_Chess_2.jpg", "images/MainExpStimuli/shapes/Red_Plus_Chess_3.jpg",
    "images/MainExpStimuli/shapes/Red_Plus_Chess_4.jpg", "images/MainExpStimuli/shapes/Red_Plus_Dots_1.jpg", "images/MainExpStimuli/shapes/Red_Plus_Dots_2.jpg", "images/MainExpStimuli/shapes/Red_Plus_Dots_3.jpg", "images/MainExpStimuli/shapes/Red_Plus_Dots_4.jpg", "images/MainExpStimuli/shapes/Red_Plus_Stripes_1.jpg", "images/MainExpStimuli/shapes/Red_Plus_Stripes_2.jpg", "images/MainExpStimuli/shapes/Red_Plus_Stripes_3.jpg", "images/MainExpStimuli/shapes/Red_Plus_Stripes_4.jpg",
    "images/MainExpStimuli/shapes/Red_Plus_Grid_1.jpg", "images/MainExpStimuli/shapes/Red_Plus_Grid_2.jpg", "images/MainExpStimuli/shapes/Red_Plus_Grid_3.jpg", "images/MainExpStimuli/shapes/Red_Plus_Grid_4.jpg", "images/MainExpStimuli/shapes/Red_Star_Chess_1.jpg", "images/MainExpStimuli/shapes/Red_Star_Chess_2.jpg", "images/MainExpStimuli/shapes/Red_Star_Chess_3.jpg", "images/MainExpStimuli/shapes/Red_Star_Chess_4.jpg", "images/MainExpStimuli/shapes/Red_Star_Dots_1.jpg",
    "images/MainExpStimuli/shapes/Red_Star_Dots_2.jpg", "images/MainExpStimuli/shapes/Red_Star_Dots_3.jpg", "images/MainExpStimuli/shapes/Red_Star_Dots_4.jpg", "images/MainExpStimuli/shapes/Red_Star_Stripes_1.jpg", "images/MainExpStimuli/shapes/Red_Star_Stripes_2.jpg", "images/MainExpStimuli/shapes/Red_Star_Stripes_3.jpg", "images/MainExpStimuli/shapes/Red_Star_Stripes_4.jpg", "images/MainExpStimuli/shapes/Red_Star_Grid_1.jpg", "images/MainExpStimuli/shapes/Red_Star_Grid_2.jpg",
    "images/MainExpStimuli/shapes/Red_Star_Grid_3.jpg", "images/MainExpStimuli/shapes/Red_Star_Grid_4.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Chess_1.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Chess_2.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Chess_3.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Chess_4.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Dots_1.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Dots_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Circle_Dots_3.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Dots_4.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Stripes_3.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Grid_1.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Grid_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Circle_Grid_3.jpg", "images/MainExpStimuli/shapes/Purple_Circle_Grid_4.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Chess_1.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Chess_2.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Chess_3.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Chess_4.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Dots_1.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Dots_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Triangle_Dots_3.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Dots_4.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Stripes_1.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Stripes_2.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Stripes_3.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Stripes_4.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Grid_1.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Grid_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Triangle_Grid_3.jpg", "images/MainExpStimuli/shapes/Purple_Triangle_Grid_4.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Chess_1.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Chess_2.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Chess_3.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Chess_4.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Dots_1.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Dots_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Plus_Dots_3.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Dots_4.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Stripes_1.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Stripes_2.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Stripes_3.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Stripes_4.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Grid_1.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Grid_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Plus_Grid_3.jpg", "images/MainExpStimuli/shapes/Purple_Plus_Grid_4.jpg", "images/MainExpStimuli/shapes/Purple_Star_Chess_1.jpg", "images/MainExpStimuli/shapes/Purple_Star_Chess_2.jpg", "images/MainExpStimuli/shapes/Purple_Star_Chess_3.jpg", "images/MainExpStimuli/shapes/Purple_Star_Chess_4.jpg", "images/MainExpStimuli/shapes/Purple_Star_Dots_1.jpg", "images/MainExpStimuli/shapes/Purple_Star_Dots_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Star_Dots_3.jpg", "images/MainExpStimuli/shapes/Purple_Star_Dots_4.jpg", "images/MainExpStimuli/shapes/Purple_Star_Stripes_1.jpg", "images/MainExpStimuli/shapes/Purple_Star_Stripes_2.jpg", "images/MainExpStimuli/shapes/Purple_Star_Stripes_3.jpg", "images/MainExpStimuli/shapes/Purple_Star_Stripes_4.jpg", "images/MainExpStimuli/shapes/Purple_Star_Grid_1.jpg", "images/MainExpStimuli/shapes/Purple_Star_Grid_2.jpg",
    "images/MainExpStimuli/shapes/Purple_Star_Grid_3.jpg", "images/MainExpStimuli/shapes/Purple_Star_Grid_4.jpg", "images/MainExpStimuli/faces/A_M_01.jpg", "images/MainExpStimuli/faces/A_M_02.jpg", "images/MainExpStimuli/faces/A_M_03.jpg", "images/MainExpStimuli/faces/A_M_04.jpg", "images/MainExpStimuli/faces/A_M_05.jpg", "images/MainExpStimuli/faces/A_M_06.jpg", "images/MainExpStimuli/faces/A_M_07.jpg", "images/MainExpStimuli/faces/A_M_08.jpg",
    "images/MainExpStimuli/faces/A_M_09.jpg", "images/MainExpStimuli/faces/A_M_10.jpg", "images/MainExpStimuli/faces/A_M_11.jpg", "images/MainExpStimuli/faces/A_M_12.jpg", "images/MainExpStimuli/faces/A_M_13.jpg", "images/MainExpStimuli/faces/A_M_14.jpg", "images/MainExpStimuli/faces/A_M_15.jpg", "images/MainExpStimuli/faces/A_M_16.jpg", "images/MainExpStimuli/faces/A_F_01.jpg", "images/MainExpStimuli/faces/A_F_02.jpg", "images/MainExpStimuli/faces/A_F_03.jpg",
    "images/MainExpStimuli/faces/A_F_04.jpg", "images/MainExpStimuli/faces/A_F_05.jpg", "images/MainExpStimuli/faces/A_F_06.jpg", "images/MainExpStimuli/faces/A_F_07.jpg", "images/MainExpStimuli/faces/A_F_08.jpg", "images/MainExpStimuli/faces/A_F_09.jpg", "images/MainExpStimuli/faces/A_F_10.jpg", "images/MainExpStimuli/faces/A_F_11.jpg", "images/MainExpStimuli/faces/A_F_12.jpg", "images/MainExpStimuli/faces/A_F_13.jpg", "images/MainExpStimuli/faces/A_F_14.jpg",
    "images/MainExpStimuli/faces/A_F_15.jpg", "images/MainExpStimuli/faces/A_F_16.jpg", "images/MainExpStimuli/faces/C_M_01.jpg", "images/MainExpStimuli/faces/C_M_02.jpg", "images/MainExpStimuli/faces/C_M_03.jpg", "images/MainExpStimuli/faces/C_M_04.jpg", "images/MainExpStimuli/faces/C_M_05.jpg", "images/MainExpStimuli/faces/C_M_06.jpg", "images/MainExpStimuli/faces/C_M_07.jpg", "images/MainExpStimuli/faces/C_M_08.jpg", "images/MainExpStimuli/faces/C_M_09.jpg",
    "images/MainExpStimuli/faces/C_M_10.jpg", "images/MainExpStimuli/faces/C_M_11.jpg", "images/MainExpStimuli/faces/C_M_12.jpg", "images/MainExpStimuli/faces/C_M_13.jpg", "images/MainExpStimuli/faces/C_M_14.jpg", "images/MainExpStimuli/faces/C_M_15.jpg", "images/MainExpStimuli/faces/C_M_16.jpg", "images/MainExpStimuli/faces/C_F_01.jpg", "images/MainExpStimuli/faces/C_F_02.jpg", "images/MainExpStimuli/faces/C_F_03.jpg", "images/MainExpStimuli/faces/C_F_04.jpg",
    "images/MainExpStimuli/faces/C_F_05.jpg", "images/MainExpStimuli/faces/C_F_06.jpg", "images/MainExpStimuli/faces/C_F_07.jpg", "images/MainExpStimuli/faces/C_F_08.jpg", "images/MainExpStimuli/faces/C_F_09.jpg", "images/MainExpStimuli/faces/C_F_10.jpg", "images/MainExpStimuli/faces/C_F_11.jpg", "images/MainExpStimuli/faces/C_F_12.jpg", "images/MainExpStimuli/faces/C_F_13.jpg", "images/MainExpStimuli/faces/C_F_14.jpg", "images/MainExpStimuli/faces/C_F_15.jpg", "images/MainExpStimuli/faces/C_F_16.jpg"])


const wcst_shapes = function () {

    const init = function () {
        preLoad.set.onComplete(wcst_shapes.instructions_pg1)

        eventTimer.cancelAllRequests();

        get_info.set_current_task("wcst_shapes")


        // create content display within the main-display div
        document.querySelector("#main-display").style.display = "flex"
        document.querySelector("#main-display").innerHTML = `
                        <div class="content-display flex flex-column justify-center f6 lh-copy" style="text-align: left">
                        </div>`

        // show load screen
        load_screen();
        preLoad.loadImages()
    }

    // triggers loading screen
    const load_screen = function () {
        document.querySelector(".content-display").innerHTML = `<div style="font-size:24px">Loading experiment...</div><div class="load loader"></div>`
        document.querySelector(".content-display").style.visibility = "visible"
    }


    ////////// INSTRUCTIONS //////////////
    const instructions_pg1 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p>In this task three cards are shown. One card appears at the top and two cards appear at the bottom, one left and one right. You have to indicate whether the upper card matches the left or right card at the bottom, by pressing the "Z" or "M" keys as soon as possible. You have up to 2 seconds to respond. You will get feedback on the screen indicating whether your choice was rewarded or not.</p>

                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/shapes/` + trials[0].image_top + `" style="width: 100px; margin-bottom: 10px"></img>
                            </div>
                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/shapes/` + trials[0].image_left + `" style="width: 100px; margin-right: 20px"></img>
                                    <img src="images/MainExpStimuli/shapes/` + trials[0].image_right + `" style="width: 100px"></img>
                            </div>
                            <p>We will go through a few examples in the next couple of pages.</p>
                            <div class="flex flex-row">
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">NEXT</a>
                            </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg2();")
        document.querySelector(".content-display").style.visibility = "visible"
    }

    const instructions_pg2 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p>If you think the top card matches the botton left card (because they share the same `+labels[0]+`), press "Z". Otherwise, if you think the top card matches the bottom right card (because they share the same `+labels[1]+`), press "M". </p>

                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/shapes/` + trials[280].image_top + `" style="width: 100px; margin-bottom: 10px"></img>
                            </div>
                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/shapes/` + trials[280].image_left + `" style="width: 100px; margin-right: 20px"></img>
                                    <img src="images/MainExpStimuli/shapes/` + trials[280].image_right + `" style="width: 100px"></img>
                            </div>
                            <div class="flex flex-row" style="">
                                <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                            </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg1();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg3();")

        document.querySelector(".content-display").style.visibility = "visible"
    }

    const instructions_pg3 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p>If you think the top card matches the botton left card (because they share the same `+labels[1]+`), press "Z". Otherwise, if you think the top card matches the bottom right card (because they share the same `+labels[0]+`), press "M". </p>

                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/shapes/` + trials[281].image_top + `" style="width: 100px; margin-bottom: 10px"></img>
                            </div>
                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/shapes/` + trials[281].image_left + `" style="width: 100px; margin-right: 20px"></img>
                                    <img src="images/MainExpStimuli/shapes/` + trials[281].image_right + `" style="width: 100px"></img>
                            </div>
                            <div class="flex flex-row" style="">
                                <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                            </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg2();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg4();")

        document.querySelector(".content-display").style.visibility = "visible"
    }

    const instructions_pg4 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p>The matching rule will not be directly told to you. However, the matching rule is based on one of the card features instructed above. The correct choice will give you a reward 80% of the time, while the incorrect choice will give you a reward 20% of the time. In other words, even if you give a response in line with the correct rule, you will sometimes not get a reward. <strong> The matching rule feature will stay the same most of the time, changing only once in a while, and your task is to always figure out which rule is currently valid. </strong> </p>
                            <div class="standard-display absolute-center">
                                    <img src="images/instructions-1.png" style="width: 750px; margin-bottom: 50px"></img>
                            </div>
                            <div class="flex flex-row" style="">
                                <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                            </div>
                        </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg3();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg5();")

        document.querySelector(".content-display").style.visibility = "visible"
    }



    const instructions_pg5 = function () {
        eventTimer.cancelAllRequests()
        let content = document.querySelector(".content-display")
        content.style.visibility = "hidden"

        content.innerHTML =
            `<h3>Instructions</h3>
            <div>
                <p>That's it! Please use the "previous" and "next" buttons if you'd like to review the instructions</p>
                <p>Before we begin the experimental trials, you will first have to complete 40 practice trials. In the practice, you will be instructed which dimension to match the cards. The rules will be written on the top of the screen only during the practice. Your accuracy will be calculated based on your ability to respond according to the rules and not on the feedback. You must get at least 90% of the practice trials correct, before you can move on to the experimental trials. If you do not get at least 90% correct, you will have to redo the practice trials. </p>
                <p>Same as the main experiment, the correct choice will give you a reward 80% of the time, while the incorrect choice will give you a reward 20% of the time. In other words, even if you give a response in line with the correct rule, you will sometimes not get a reward. However, as long as you respond to the correct rule, it will be counted as accurate, regardless whether you are rewarded or not.</p>
                <p>When you are ready to begin the practice trials, press START. The sequence will begin immediately after pressing START.</p>
            </div>

                <div class="flex flex-row" style="">
                    <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                    <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">START</a>
                </div>
            </div>
            `
        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg4();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.start_exp();")

        content.style.visibility = "visible"
    }


    // transfer task instructions //

    const instructions_pg6 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p style="font-size:18">Now we are at the second half of the experiment. You will now be making judgements on pictures of faces instead. The instructions for the experiment will remain the same, but now you have to match pictures according to <strong> gender (male or female) </strong> and <strong> race (Asian or Caucasian) </strong> dimensions.</p>
                            <p>We will go through a few examples in the next couple of pages.</p>
                            <div class="flex flex-row">
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">NEXT</a>
                            </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg7();")
        document.querySelector(".content-display").style.visibility = "visible"
    }

    const instructions_pg7 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p>If you think the top card matches the botton left card (because they are the same `+ labels[2] + `), press "Z". Otherwise, if you think the top card matches the bottom right card (because they are the same ` + labels[3] + `), press "M". </p>

                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/faces/` + trials[282].image_top + `" style="width: 100px; margin-bottom: 10px"></img>
                            </div>
                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/faces/` + trials[282].image_left + `" style="width: 100px; margin-right: 20px"></img>
                                    <img src="images/MainExpStimuli/faces/` + trials[282].image_right + `" style="width: 100px"></img>
                            </div>
                            <div class="flex flex-row" style="">
                                <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                            </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg6();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg8();")

        document.querySelector(".content-display").style.visibility = "visible"
    }

    const instructions_pg8 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p>If you think the top card matches the botton left card (because they are the same `+ labels[3] + `), press "Z". Otherwise, if you think the top card matches the bottom right card (because they are the same ` + labels[2] + `), press "M". </p>

                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/faces/` + trials[283].image_top + `" style="width: 100px; margin-bottom: 10px"></img>
                            </div>
                            <div class="standard-display absolute-center">
                                    <img src="images/MainExpStimuli/faces/` + trials[283].image_left + `" style="width: 100px; margin-right: 20px"></img>
                                    <img src="images/MainExpStimuli/faces/` + trials[283].image_right + `" style="width: 100px"></img>
                            </div>
                            <div class="flex flex-row" style="">
                                <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                            </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg7();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg9();")

        document.querySelector(".content-display").style.visibility = "visible"
    }

    const instructions_pg9 = function () {
        document.querySelector(".content-display").style.visibility = "hidden"


        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div>
                            <p>The matching rule will not be directly told to you. However, the matching rule is based on one of the card features instructed above. The correct choice will give you a reward 80% of the time, while the incorrect choice will give you a reward 20% of the time. In other words, even if you give a response in line with the correct rule, you will sometimes not get a reward. The matching rule feature will change once in a while, and your task is to always figure out which rule is currently valid. </p>
                            <div class="standard-display absolute-center">
                                    <img src="images/instructions-2.png" style="width: 750px; margin-bottom: 50px"></img>
                            </div>
                            <div class="flex flex-row" style="">
                                <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                                <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                            </div>
                        </div>
                        </div>
                        `

        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg8();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg10();")

        document.querySelector(".content-display").style.visibility = "visible"
    }



    const instructions_pg10 = function () {
        eventTimer.cancelAllRequests()
        let content = document.querySelector(".content-display")
        content.style.visibility = "hidden"

        content.innerHTML =
            `<h3>Instructions</h3>
            <div>
                <p>That's it! Please use the "previous" and "next" buttons if you'd like to review the instructions</p>
				<p>There is no practice for this, and we will go directly into the second part.</p>
                <p>When you are ready to begin the practice trials, press START. The sequence will begin immediately after pressing START.</p>
            </div>

                <div class="flex flex-row" style="">
                    <a id="dyn-bttn-2" class="bttn b-left f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">PREVIOUS</a>
                    <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">START</a>
                </div>
            </div>
            `
        document.querySelector("#dyn-bttn-2").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg9();")
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.start_exp();")

        content.style.visibility = "visible"
    }

    /////////// EXPERIMENT /////////////////

    let trial_counter = -1,
        allow_keys = false,
        time1,
        time2,
        timer,
        responded,
        allow_spacebar = false,
        mainexp_acc = 0,
        practice_acc = 0,
        bonus_reward = 0,
        nPractice = 40,
        nMain = 240,
        second_half = 0

    const start_exp = function () {
        document.addEventListener("keydown", keydown, false)
        document.querySelector("#main-display").innerHTML = `<div class="standard-display absolute-center">/div>`

        fixate_0();
    }

    const fixate_0 = function () {
        allow_keys = false
        allow_spacebar = false

        document.querySelector("#main-display").innerHTML =
            `<div class="standard-display absolute-center">
                <p style="font-size: 72px">+</p>
            </div>`
        timer = eventTimer.setTimeout(show_choiceDisplay, 750)
    }


    const show_choiceDisplay = function () {

        // increase our trial counter
        trial_counter++


        if (trial_counter >= nPractice + nMain / 2 && second_half == 0) {
            second_half = 1
            score = (100 * mainexp_acc / 120)
            document.querySelector("#main-display").innerHTML =
                `<div class="content-display">
                    <div>
                        <p style="font-size: 72px">Your accuracy for the first half is `+ score.toFixed(2) + `%</p>
                        <p style="font-size: 72px">Please press NEXT to move on to the second half</p>
                    </div>
                    <div class="flex flex-row" style="">
                    <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                    </div>
                </div>`
            document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.instructions_pg6();")
            return;
        }

        if (trial_counter >= nPractice + nMain) {
            score = (100 * mainexp_acc / 240)
            if (score < 65) {
                document.querySelector("#main-display").innerHTML =
                    `<div class="content-display">
                    <div>
                        <p style="font-size: 72px">Your total accuracy is `+ score.toFixed(2) + `%</p>
                        <p style="font-size: 36px">You did not meet the accuracy criteria stated at the beginning of the experiment. Therefore you will not be given a completion code. Submission of the HIT will result in rejection. If you have any questions, please contact the requester: egnerlab.experiments@gmail.com </p>
                    </div>
                </div>`
            } else {
                bonus = 0.01 * bonus_reward;
                document.querySelector("#main-display").innerHTML =
                    `<div class="content-display">
                    <div>
                        <p style="font-size: 72px">Your accuracy is `+ score.toFixed(2) + `%</p>
                        <p style="font-size: 36px">In addition to the base pay of $2.50</p>
                        <p style="font-size: 36px">You earned an extra $ `+ bonus.toFixed(2) + `</p>
                        <br>
                        <p style="font-size: 14px">You will receive the two payments seperately. You will recieve the base pay when the researcher approves the HIT and you will recieve the extra reward as a bonus. Please allow some time for the payment to be processed as the researcher will need to process each individual participant's bonus seperately. We aim to grant the bonus within 24 hours of your HIT submission.</p>
                    </div>
                    <div class="flex flex-row" style="">
                        <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">NEXT</a>
                    </div>
                </div>`
            }
            document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: master.next();")
            return;
        }

        time1 = window.performance.now();
        allow_keys = true

        document.querySelector("#main-display").style.visibility = "hidden"
        if (second_half == 0) {
        document.querySelector("#main-display").innerHTML =
            `<div>
                <div class="standard-display absolute-center">
                    <img src="images/MainExpStimuli/shapes/` + trials[trial_counter].image_top + `" style="width: 200px; margin-bottom: 20px"></img>
                </div>
                <div class="standard-display absolute-center">
                    <img src="images/MainExpStimuli/shapes/` + trials[trial_counter].image_left + `" style="width: 200px; margin-right: 40px"></img>
                    <img src="images/MainExpStimuli/shapes/` + trials[trial_counter].image_right + `" style="width: 200px"></img>
                </div>
            </div>`
        } else if (second_half == 1) {
            document.querySelector("#main-display").innerHTML =
                `<div>
                    <div class="standard-display absolute-center">
                        <img src="images/MainExpStimuli/faces/` + trials[trial_counter].image_top + `" style="width: 200px; margin-bottom: 20px"></img>
                    </div>
                    <div class="standard-display absolute-center">
                        <img src="images/MainExpStimuli/faces/` + trials[trial_counter].image_left + `" style="width: 200px; margin-right: 40px"></img>
                        <img src="images/MainExpStimuli/faces/` + trials[trial_counter].image_right + `" style="width: 200px"></img>
                    </div>
                </div>`
        }
        if (trial_counter < nPractice) {
            document.querySelector("#main-display").innerHTML =
                `<div>
                <div class="standard-display absolute-center">
                    <p style="font-size: 24px">Match according to `+ trials[trial_counter].type + `</p>
                </div>
                <div class="standard-display absolute-center">
                    <img src="images/MainExpStimuli/shapes/` + trials[trial_counter].image_top + `" style="width: 200px; margin-bottom: 20px"></img>
                </div>
                <div class="standard-display absolute-center">
                    <img src="images/MainExpStimuli/shapes/` + trials[trial_counter].image_left + `" style="width: 200px; margin-right: 40px"></img>
                    <img src="images/MainExpStimuli/shapes/` + trials[trial_counter].image_right + `" style="width: 200px"></img>
                </div>
            </div>`
        }
        document.querySelector("#main-display").style.visibility = "visible"

        timer = eventTimer.setTimeout(target_timeout, 2000)
    }

    const target_timeout = function () {
        allow_spacebar = true
        allow_keys = false

        document.querySelector("#main-display").innerHTML =
            `<div class="standard-display absolute-center">
            <div>
            <p style="font-size: 36px">Too slow!</p> <br>
            <p style="font-size: 36px">Press the spacebar to continue</p>
            </div>
        </div>
        `
        trials[trial_counter].response = "none"
        trials[trial_counter].response_time = 0
        trials[trial_counter].response_acc = trials[trial_counter].response == trials[trial_counter].answer
    }


    const feedback = function () {
        allow_keys = false
        allow_spacebar = false

        if (trial_counter == nPractice - 1) {
            document.querySelector("#main-display").innerHTML =
                `<div class="standard-display absolute-center">
                    <p style="font-size: 36px"></p>
                </div>
                `
            timer = eventTimer.setTimeout(end_practice, 500)
            return;
        }

        if (wcst_shapes.trials[trial_counter].answer == wcst_shapes.trials[trial_counter].response && wcst_shapes.trials[trial_counter].reward_validity === 1) {
            bonus_reward++
            document.querySelector("#main-display").innerHTML =
                `<div class="standard-display absolute-center">
                    <p style="font-size: 36px; color:green">Bonus +$0.01</p>
                </div>
                `
            timer = eventTimer.setTimeout(end_trial, 500)

        } else if (wcst_shapes.trials[trial_counter].answer !== wcst_shapes.trials[trial_counter].response && wcst_shapes.trials[trial_counter].reward_validity === 0) {
            bonus_reward++
            document.querySelector("#main-display").innerHTML =
                `<div class="standard-display absolute-center">
                        <p style="font-size: 36px; color:green">Bonus +$0.01</p>
                    </div>
                    `
            timer = eventTimer.setTimeout(end_trial, 500)
        } else if (wcst_shapes.trials[trial_counter].answer == wcst_shapes.trials[trial_counter].response && wcst_shapes.trials[trial_counter].reward_validity === 0) {
            document.querySelector("#main-display").innerHTML =
                `<div class="standard-display absolute-center">
                    <p style="font-size: 36px; color:red">Oh no!</p> <br>
                </div>
                `
            timer = eventTimer.setTimeout(end_trial, 500)
        } else if (wcst_shapes.trials[trial_counter].answer !== wcst_shapes.trials[trial_counter].response && wcst_shapes.trials[trial_counter].reward_validity === 1) {
            document.querySelector("#main-display").innerHTML =
                `<div class="standard-display absolute-center">
                    <p style="font-size: 36px; color:red">Oh no!</p> <br>
                </div>
                `
            timer = eventTimer.setTimeout(end_trial, 500)
        }
    }

    const end_trial = function () {
        allow_keys = false
        allow_spacebar = false

        document.querySelector("#main-display").innerHTML =
            `<div class="standard-display absolute-center">
            <p style="font-size: 72px">+</p>
        </div>
        `
        timer = eventTimer.setTimeout(show_choiceDisplay, 1000)
    }

    const end_practice = function () {
        eventTimer.cancelAllRequests()

        if (practice_acc >= 36) {
            // create content display within the main-display div
            document.querySelector("#main-display").style.display = "flex"
            document.querySelector("#main-display").innerHTML = `
                        <div class="content-display flex flex-column justify-center f6 lh-copy" style="text-align: left">
                        </div>`

            document.querySelector(".content-display").style.visibility = "hidden"


            document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div><p>Great! You've completed the practice trials and can move on to the main experiment.</p>
                            <p>The experimental trials will be exactly the same as the practice trials, but you will not be instructed what the matching rule is, and you will need to figure it out yourself. </p>
                            <p><strong>Reminder:</strong> In this task three cards are shown. One card appears at the top and two cards appear at the bottom, one left and one right. You have to indicate whether the upper card matches the left or right card at the bottom, by pressing the "Z" or "M" key as soon as possible. You have up to 2 seconds to make your response. The matching rule is based on one of the card features (color, shape, filling, or number). The correct choice will give you a reward 80% of the time, while the incorrect choice will be give you a reward 20% of the time. In other words, even if you give a response in line with the correct rule, you will sometimes not get a reward. Your accuracy is calculated based on whether you responded to the correct rules, regardless of whether you were rewarded or not on each trial. <strong> The matching rule feature will stay the same most of the time, changing only once in a while, and your task is to always figure out which rule is currently valid.</strong></p>
                            <p style="color:red">Reminder: To ensure data quality and to reward people who have put effort into doing the experiment and did the task correctly, we will reject HITs if we feel you have completeted the experiment in a unsatisfactory standard, and we will give bonus rewards for those who have met criteria. Each rewarded trial gets you an additional $0.01, for example, if you get 190 rewarded trials, you will get a total of $4.40 ($2.50 + $1.90) after completion of the HIT. You will need to have an accuracy of at least 65% for the HIT to be approved, otherwise your HIT will be rejected. If you score above 65% accuracy, you will be awarded addition bonus money based on your performance. </p>
                            <p style="color:red">If you feel that the task is too difficult, boring, or want to quit the experiment for whatever reason, you are welcome to close the window and return the HIT at any point duing the experiment</p>
                            <p>When you are ready to begin the experimental trials, press start.</p>
                            <div class="flex flex-row">
                            <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">START MAIN EXPERIMENT</a>
                        </div>
                        </div>
                        `

            document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.fixate_0();")
            document.querySelector(".content-display").style.visibility = "visible"

        } else {
            redo_practice();
        }
    }


    const redo_practice = function () {
        trial_counter = -1
        practice_acc = 0

        // create content display within the main-display div
        document.querySelector("#main-display").style.display = "flex"
        document.querySelector("#main-display").innerHTML = `
                        <div class="content-display flex flex-column justify-center f6 lh-copy" style="text-align: left">
                        </div>`

        document.querySelector(".content-display").style.visibility = "hidden"
        document.querySelector(".content-display").innerHTML = `
                        <h3> Instructions </h3>
                        <div><p>Let's practice again just to make sure you have gotten everything clear.</p>
                            <p>Reminder: In this task three cards are shown. One card appears at the top and two cards appear at the bottom, one left and one right. You have to indicate whether the upper card matches the left or right card at the bottom, by pressing the "Z" or "M" key as soon as possible. During the practice, the matching rule will be written on the top of the screen. Your accuracy will be calculated based on your ability to respond according to the rules and not on the feedback. The correct choice will give you a reward 80% of the time, while the incorrect choice will give you a reward 20% of the time. In other words, even if you give a response in line with the correct rule, you will sometimes not get a reward. </p>
                            <p> You will respond as quickly and as accurately as possible using the keyboard. You will press "Z" for yes (same) or "M" for no (different). Press start to redo the practice trials.</p>
                            <div class="flex flex-row">
                            <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-dark-gray" href="#0">START PRACTICE</a>
                        </div>
                        </div>
                        `
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: wcst_shapes.fixate_0();")
        document.querySelector(".content-display").style.visibility = "visible"
    }


    /// on keydown event // added as event listener on init
    let keydown = function (event) {
        console.log(event.keyCode)
        // log key time
        time2 = window.performance.now();
        let key = event.keyCode ? event.keyCode : event.which;

        // prevent backspace from exiting page (maybe?)
        if (event.keyCode == 8) {
            event.preventDefault();
            return;
        }

        if (allow_spacebar == true) {
            if (key == 32) {
                fixate_0();
                return
            }
        }

        // do nothing if allow_keys is false
        if (allow_keys == false) {
            return;
        }

        if (key == 77 | key == 90) {
            eventTimer.cancelRequest(timer)

            responded = true;
            allow_keys = false;

            trials[trial_counter].response = (key == 90) ? "left" : "right";
            trials[trial_counter].response_time = time2 - time1
            trials[trial_counter].response_acc = trials[trial_counter].response == trials[trial_counter].answer

            if (trials[trial_counter].response == trials[trial_counter].answer) {
                practice_acc++
                if (trial_counter > nPractice) {
                    mainexp_acc++
                }
            }

            feedback()
        }
    };


    const create_trials = function () {
        /* shuffle an array */
        function shuffle(array) {
            var tmp, current, top = array.length;
            if (top)
                while (--top) {
                    current = Math.floor(Math.random() * (top + 1));
                    tmp = array[current];
                    array[current] = array[top];
                    array[top] = tmp;
                }

            return array;
        }

/*         let volatility
        volatility = shuffle(["high", "low"])

        let sequences = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]]
        let sequence
        if (volatility[0] === "high") {
            sequence = sequences[0]
        } else {
            sequence = sequences[1]
        } */
        let volatility = "high"
        let sequence = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]

        let practice_sequence = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]


        // Make reward validity (80%). Constrain that there are no 2 consecutive false feedbacks or more (but only for transfer task)
        let reward_list1 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        let reward_list2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        let reward_validity = shuffle(reward_list1);
        let temp_list = [].concat(shuffle(reward_list2));
        for (i = 0; i < reward_list2.length; i++) {
            if (temp_list[0] === 0) {
                /* if 0 then add the first one over and then add a 1 */
                reward_validity.push(temp_list.shift())
                reward_validity.push(1)
            } else {
                reward_validity.push(temp_list.shift())
            }
        }

        let practice_reward_validity = shuffle([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

        // function that creates images
        function select_features(task_set, distractor_set, LeftRight) {
            let top_img = "",
                left_img = "",
                right_img = ""

            // shapes (first half of experiment)
            if (task_set == "color" || task_set == "shape" || task_set == "filling" || task_set == "number") {
                // randomly create images
                top_img = [shuffle(["Blue", "Green", "Red", "Purple"])[0], shuffle(["Circle", "Triangle", "Plus", "Star"])[0], shuffle(["Chess", "Dots", "Stripes", "Grid"])[0], shuffle(["1", "2", "3", "4"])[0]]
                left_img = [shuffle(["Blue", "Green", "Red", "Purple"])[0], shuffle(["Circle", "Triangle", "Plus", "Star"])[0], shuffle(["Chess", "Dots", "Stripes", "Grid"])[0], shuffle(["1", "2", "3", "4"])[0]]
                right_img = [shuffle(["Blue", "Green", "Red", "Purple"])[0], shuffle(["Circle", "Triangle", "Plus", "Star"])[0], shuffle(["Chess", "Dots", "Stripes", "Grid"])[0], shuffle(["1", "2", "3", "4"])[0]]

                // make sure that all the other features are different
                feature0 = shuffle(["Blue", "Green", "Red", "Purple"])
                top_img[0] = feature0[0]
                left_img[0] = feature0[1]
                right_img[0] = feature0[2]

                feature1 = shuffle(["Circle", "Triangle", "Plus", "Star"])
                top_img[1] = feature1[0]
                left_img[1] = feature1[1]
                right_img[1] = feature1[2]

                feature2 = shuffle(["Chess", "Dots", "Stripes", "Grid"])
                top_img[2] = feature2[0]
                left_img[2] = feature2[1]
                right_img[2] = feature2[2]

                feature4 = shuffle(["1", "2", "3", "4"])
                top_img[3] = feature4[0]
                left_img[3] = feature4[1]
                right_img[3] = feature4[2]

                // make sure that the selected target feature is the same
                if (task_set == "color") {
                    if (LeftRight == "left") {
                        left_img[0] = top_img[0]
                    } else if (LeftRight == "right") {
                        right_img[0] = top_img[0]
                    }
                }

                if (task_set == "shape") {
                    if (LeftRight == "left") {
                        left_img[1] = top_img[1]
                    } else if (LeftRight == "right") {
                        right_img[1] = top_img[1]
                    }
                }

                if (task_set == "filling") {
                    if (LeftRight == "left") {
                        left_img[2] = top_img[2]
                    } else if (LeftRight == "right") {
                        right_img[2] = top_img[2]
                    }
                }

                if (task_set == "number") {
                    if (LeftRight == "left") {
                        left_img[3] = top_img[3]
                    } else if (LeftRight == "right") {
                        right_img[3] = top_img[3]
                    }
                }

                // make sure that the distractor feature is the same
                if (distractor_set == "color") {
                    if (LeftRight == "left") {
                        right_img[0] = top_img[0]
                    } else if (LeftRight == "right") {
                        left_img[0] = top_img[0]
                    }
                }

                if (distractor_set == "shape") {
                    if (LeftRight == "left") {
                        right_img[1] = top_img[1]
                    } else if (LeftRight == "right") {
                        left_img[1] = top_img[1]
                    }
                }

                if (distractor_set == "filling") {
                    if (LeftRight == "left") {
                        right_img[2] = top_img[2]
                    } else if (LeftRight == "right") {
                        left_img[2] = top_img[2]
                    }
                }

                if (distractor_set == "number") {
                    if (LeftRight == "left") {
                        right_img[3] = top_img[3]
                    } else if (LeftRight == "right") {
                        left_img[3] = top_img[3]
                    }
                }
            }

            // shapes (first half of experiment) 
            else if (task_set == "race" || task_set == "gender") {
                // randomly create images
                top_img = [shuffle(["A", "C"])[0], shuffle(["M", "F"])[0], shuffle(["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"])[0]]
                left_img = [shuffle(["A", "C"])[0], shuffle(["M", "F"])[0], shuffle(["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"])[0]]
                right_img = [shuffle(["A", "C"])[0], shuffle(["M", "F"])[0], shuffle(["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"])[0]]

                // get top image feature
                feature0 = shuffle(["A", "C"])
                top_img[0] = feature0[0]

                feature1 = shuffle(["M", "F"])
                top_img[1] = feature1[0]

                // make sure there are no duplicate images
                feature2 = shuffle(["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16"])
                top_img[2] = feature2[0]
                left_img[2] = feature2[1]
                right_img[2] = feature2[2]

                // make sure that the selected target feature is the same & that the distractor feature is the same
                if (task_set == "race") {
                    if (LeftRight == "left") {
                        left_img[0] = top_img[0] //target
                        left_img[1] = feature1[1]
                        right_img[1] = top_img[1] //distractor
                        right_img[0] = feature0[1]
                    } else if (LeftRight == "right") {
                        right_img[0] = top_img[0] //target
                        right_img[1] = feature1[1]
                        left_img[1] = top_img[1] //distractor
                        left_img[0] = feature0[1]
                    }
                }

                if (task_set == "gender") {
                    if (LeftRight == "left") {
                        left_img[1] = top_img[1] //target
                        left_img[0] = feature0[1]
                        right_img[0] = top_img[0] //distractor
                        right_img[1] = feature1[1]
                    } else if (LeftRight == "right") {
                        right_img[1] = top_img[1] //target
                        right_img[0] = feature0[1]
                        left_img[0] = top_img[0] //distractor
                        left_img[1] = feature1[1]
                    }
                }
            }

            // create image names
            top_img = top_img.join("_") + ".jpg"
            left_img = left_img.join("_") + ".jpg"
            right_img = right_img.join("_") + ".jpg"

            return ({
                top_img: top_img,
                left_img: left_img,
                right_img: right_img
            })
        }



        shape_labels = shuffle(["color", "shape", "filling", "number"])
        shape_labs = shape_labels.slice(0, 2)
        labels = shape_labs.concat(shuffle(["race", "gender"]))

        let practice = [],
            LeftRight, feature
        for (i = 0; i < practice_sequence.length; i++) {

            LeftRight = shuffle(["left", "right"])[0]
            feature = select_features(labels[practice_sequence[i]], labels[1 - practice_sequence[i]], LeftRight)

            practice.push(new Data_row({
                time_end: "incomplete",
                practice: true,
                trial: i,
                type: labels[practice_sequence[i]],
                sequence: practice_sequence[i],
                reward_validity: practice_reward_validity[i],
                answer: LeftRight,
                image_top: feature.top_img,
                image_left: feature.left_img,
                image_right: feature.right_img
            }))

        }

        let trials = []
        for (i = 0; i < sequence.length; i++) {
            LeftRight = shuffle(["left", "right"])[0]

            if (sequence[i] == 0) {
                feature = select_features(labels[0], labels[1], LeftRight)
            } else if (sequence[i] == 1) {
                feature = select_features(labels[1], labels[0], LeftRight)
            } else if (sequence[i] == 2) {
                feature = select_features(labels[2], labels[3], LeftRight)
            } else if (sequence[i] == 3) {
                feature = select_features(labels[3], labels[2], LeftRight)
            }

            trials.push(new Data_row({
                time_end: "incomplete",
                practice: false,
                volatility: volatility,
                trial: i,
                type: labels[sequence[i]],
                sequence: sequence[i],
                reward_validity: reward_validity[i],
                answer: LeftRight,
                image_top: feature.top_img,
                image_left: feature.left_img,
                image_right: feature.right_img
            }))

        }


        let instruction_example = []
        for (i = 0; i < 4; i++) {
            if (i == 0) {
                feature = select_features(labels[0], labels[1], "left")
            } else if (i == 1) {
                feature = select_features(labels[1], labels[0], "left")
            } else if (i == 2) {
                feature = select_features(labels[2], labels[3], "left")
            } else if (i == 3) {
                feature = select_features(labels[3], labels[2], "left")
            }

            instruction_example.push(new Data_row({
                trial: "instruction example",
                type: labels[sequence[i]],
                image_top: feature.top_img,
                image_left: feature.left_img,
                image_right: feature.right_img
            }))
        }

        return practice.concat(trials).concat(instruction_example)
    }

    let trials = create_trials();

    return {
        init: init,
        load_screen: load_screen,
        instructions_pg1: instructions_pg1,
        instructions_pg2: instructions_pg2,
        instructions_pg3: instructions_pg3,
        instructions_pg4: instructions_pg4,
        instructions_pg5: instructions_pg5,
        instructions_pg6: instructions_pg6,
        instructions_pg7: instructions_pg7,
        instructions_pg8: instructions_pg8,
        instructions_pg9: instructions_pg9,
        instructions_pg10: instructions_pg10,
        start_exp: start_exp,
        fixate_0: fixate_0,
        show_choiceDisplay: show_choiceDisplay,
        target_timeout: target_timeout,
        end_trial: end_trial,
        trials: trials
    }

}();
