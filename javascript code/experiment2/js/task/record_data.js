function getAllUrlParams(url) {

    // get query string from url (optional) or window
    var queryString = url ? url.split('?')[1] : window.location.search.slice(1);

    // we'll store the parameters here
    var obj = {};

    // if query string exists
    if (queryString) {

        // stuff after # is not part of query string, so get rid of it
        queryString = queryString.split('#')[0];

        // split our query string into its component parts
        var arr = queryString.split('&');

        for (var i = 0; i < arr.length; i++) {
            // separate the keys and the values
            var a = arr[i].split('=');

            // set parameter name and value (use 'true' if empty)
            var paramName = a[0];
            var paramValue = typeof (a[1]) === 'undefined' ? true : a[1];

            // (optional) keep case consistent
            paramName = paramName.toLowerCase();
            if (typeof paramValue === 'string') paramValue = paramValue.toLowerCase();

            // if the paramName ends with square brackets, e.g. colors[] or colors[2]
            if (paramName.match(/\[(\d+)?\]$/)) {

                // create key if it doesn't exist
                var key = paramName.replace(/\[(\d+)?\]/, '');
                if (!obj[key]) obj[key] = [];

                // if it's an indexed array e.g. colors[2]
                if (paramName.match(/\[\d+\]$/)) {
                    // get the index value and add the entry at the appropriate position
                    var index = /\[(\d+)\]/.exec(paramName)[1];
                    obj[key][index] = paramValue;
                } else {
                    // otherwise add the value to the end of the array
                    obj[key].push(paramValue);
                }
            } else {
                // we're dealing with a string
                if (!obj[paramName]) {
                    // if it doesn't exist, create property
                    obj[paramName] = paramValue;
                } else if (obj[paramName] && typeof obj[paramName] === 'string') {
                    // if property does exist and it's a string, convert it to an array
                    obj[paramName] = [obj[paramName]];
                    obj[paramName].push(paramValue);
                } else {
                    // otherwise add the property
                    obj[paramName].push(paramValue);
                }
            }
        }
    }

    return obj;
}

// store participant info //
const get_info = function () {

    //set participant values
    function getRandomString(length, chars) {
        var result = '';
        for (var i = length; i > 0; --i) result += chars[Math.round(Math.random() * (chars.length - 1))];
        return result;
    }



    const studyid = '2020-0188';
    const ss_code = getRandomString(8, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
    const exp_date = moment().format('YYYY-MM-DD')
    const exp_start = moment().format('HH:mm:ss')

    let current_task = "landing"

    function get_ss_code() {
        return (ss_code)
    }

    function get_start() {
        return (exp_start)
    }

    function get_date() {
        return (exp_date)
    }


    function get_studyid() {
        return (studyid)
    }


    function get_current_task() {
        return (current_task)
    }

    function set_current_task(x) {
        current_task = x
        return (current_task)
    }

    const url_params = getAllUrlParams();

    return ({
        studyid: get_studyid,
        ss_code: get_ss_code,
        start: get_start,
        date: get_date,
        get_current_task: get_current_task,
        set_current_task: set_current_task
    })

}();

sessionStorage.setItem("sscode", get_info.ss_code());

let mt = getAllUrlParams()

if(mt.hitid == ""){mt.hitid = "NA"}
if(mt.workerid == ""){mt.workerid  = "NA"}
if(mt.assid == ""){mt.assid = "NA"}


// data formatting
// creates an object class with these defaults...
// makes sure all data has the same formatting
function Data_row(obj) {
    this.workerId = mt.workerid;
    this.hitId = mt.hitid;
    this.assignmentId = mt.assid;

    // defaults
    this.subject = get_info.ss_code();
    this.studyid = get_info.studyid();
    this.exp_date = get_info.date();
    this.exp_start = get_info.start();
    this.exp_end = "incomplete";
    this.time_start = "NA";
    this.time_end = "NA";
    this.trial = "NA";


    this.type = "NA";
    this.reward_validity = "NA";
    this.answer = "NA";
    this.image_top = "NA";
    this.image_left = "NA";
    this.image_right = "NA";
    this.response = "NA";
    this.response_time = "NA";
    this.response_acc = "NA";
    this.volatility = "NA";

    this.age = "NA";
    this.race= "NA";
    this.gender= "NA";
    this.ethnicity= "NA";
    this.color= "NA";
    this.vision= "NA";
    this.neuro= "NA";


    // transfer properties from arg to this
    for (var prop in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, prop)) {
            this[prop] = obj[prop]
        }
    };
}


function create_form() {
    let formHTML = [
            "<form id='sendtoPHP' method='post' action='REPLACE WITH YOUR PHP FILE' style='display: none'>",
                "<input type='hidden' name='put-assignmentid-here' id = 'put-assignmentid-here' value = ''/>",
                "<input type='hidden' name='put-workerid-here' id = 'put-workerid-here' value = ''/>",
                "<input type='hidden' name='put-hitid-here' id = 'put-hitid-here' value = ''/>",
                "<input type='hidden' name='put-studyid-here' id = 'put-studyid-here' value = ''/>",
                "<input type='hidden' name='put-sscode-here' id = 'put-sscode-here' value = ''/>",
                "<input type='hidden' name='put-data-here' id = 'put-data-here' value = ''/>",
                "<input type='hidden' name='experiment-name' id = 'experiment-name' value='Meta_Flexibility' />",
            "</form>"

            ].join("\n")

    document.querySelector("body").innerHTML += formHTML

    submit_data();
}

//submit data
function submit_data() {
    let data = []

    // collect each task dataset
    data = data.concat(wcst_shapes.trials)
    data = data.concat(demographics.q_array)

    // add exp-end time to each row
    let end_time = moment().format('HH:mm:ss')
    for(i = 0; i < data.length; i++){
        data[i].exp_end = end_time
    }

    // convert array of objects to string
    data = array_to_text(data)

    // submit data
    document.getElementById('put-assignmentid-here').value = mt.assid;
    document.getElementById('put-workerid-here').value = mt.workerid;
    document.getElementById('put-hitid-here').value = mt.hitid;
    document.getElementById('put-studyid-here').value = get_info.studyid();
    document.getElementById('put-sscode-here').value = get_info.ss_code();
    document.getElementById('put-data-here').value = data;
    document.getElementById('sendtoPHP').submit();
}


function array_to_text(args) {
        var result, ctr, keys, columnDelimiter, lineDelimiter, data;

        data = args || null;
        if (data == null || !data.length) {
            return null;
        }

        columnDelimiter = args.columnDelimiter || ',';
        lineDelimiter = args.lineDelimiter || '\n';

        keys = Object.keys(data[0]);

        result = '';
        result += keys.join(columnDelimiter);
        result += lineDelimiter;

        data.forEach(function(item) {
            ctr = 0;
            keys.forEach(function(key) {
                if (ctr > 0) result += columnDelimiter;

                result += '"' + item[key] + '"';
                ctr++;
            });
            result += lineDelimiter;
        });

        return result;
    }

function collect_data(){



}
