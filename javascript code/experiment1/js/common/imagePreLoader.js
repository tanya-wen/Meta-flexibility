
/**
 * @fileoverview An image preloader
 * 
 * @link https://github.com/nbrosowsky/preloader
 * @author N.P. Brosowsky <nbrosowsky@gmail.com>
 * 
 */


var preLoad = function () {
    'use strict';

    var percentage = 0,
        nProcessed = 0,
        yourImages = [], //image array with URLs
        preImages = [],
        imgLoad = [],
        imgFail = [],
        check = [],
        progress = "#progress",
        display = false,
        success = 0,
        fail = 0


    var onComplete = function(){}


    // helper function // adds a base url to an array of image filenames
    // automatically adds to the yourImages
    function addURL(baseURL, imageList) {
        var list

        // check if array or string
        if (Object.prototype.toString.call(imageList) === '[object Array]') {
            list = imageList
        } else if (Object.prototype.toString.call(imageList) === "[object String]") {
            list = [].concat(imageList)
        } else {
            return
        }
        //create URL array from imageList
        for (var i = 0; i <= list.length - 1; ++i) {
            yourImages[i] = baseURL + list[i];
        }

        return yourImages
    }

    // send image array to preload queue
    // must have the full URL // if not use the addURL function
    function addImages(imageList) {
        var list
        // check if array or string
        if (Object.prototype.toString.call(imageList) === '[object Array]') {
            list = imageList
        } else if (Object.prototype.toString.call(imageList) === "[object String]") {
            list = [].concat(imageList)
        } else {
            return
        }

        yourImages = imageList;

        return yourImages
    }

    function loadImages() {

        
        if (nProcessed-1 < yourImages.length) {
            preImages[nProcessed] = new Image();
            preImages[nProcessed].onload = function () {
                imgLoad.push(preImages[nProcessed])
                success++;
                nProcessed++;
                checkLoad();

            };

            preImages[nProcessed].onerror = function () {
                imgFail.push(preImages[nProcessed])
                fail++;
                nProcessed++;
                checkLoad();


            };
            
            preImages[nProcessed].src = yourImages[nProcessed];
        }
        
        return nProcessed
    }

    function checkLoad() {

        percentage = Math.round((nProcessed / yourImages.length) * 100);
       // console.log("loading images... " + Math.round((nProcessed / yourImages.length) * 100) + " % complete")
        
        if (display) {
            // add to progress percentage //
            document.querySelector(progress).innerHTML = percentage + "%";
        }


        // if loading incomplete, continue loading //
        if (nProcessed < yourImages.length) {
            loadImages();
        } else {
			console.log(yourImages)
            onComplete();
        }


    }

    /// Force a manual check on whether all images are displayed or not //
    function manualCheck() {
        return nProcessed >= yourImages.length
    }

    var get = {
        percentage: function () {
            return percentage
        },
        Ntotal: function () {
            return yourImages.length
        },
        Nsuccess: function () {
            return success
        },
        Nfail: function () {
            return fail
        },
        progressDiv: function () {
            var d = progress
            return d
        },
        loaded: function () {
            return imgLoad
        },
        failed: function () {
            return imgFail
        },
        display: function () {
            return display
        },
        yourImages: function () {
            return yourImages
        },
        preImages: function () {
            return preImages
        }

    }

    var set = {

        progressDiv: function (div) {
            progress = div;
            return progress
        },

        onComplete: function (fun) {
            if (typeof fun === "function") {
                onComplete = fun
                return fun
            }
        },

        display: function (dis) {
            if (typeof (dis) === "boolean") {
                display = dis;
                return display
            }
        }
    }

    return {
        "get": get,
        "set": set,
        "addURL": addURL,
        "addImages": addImages,
        "loadImages": loadImages,
        "checkLoad": checkLoad,
        "manualCheck": manualCheck
    }
}();
