const master = function () {
    let phase = -1;

    let list = [
        landing.init,
        wcst_shapes.init,
        demographics.init
    ]


    let next = function () {
            phase++
     
        if (phase > list.length - 1) {
            create_form();
            return;
        }

        eventTimer.cancelAllRequests();
        list[phase]();
        return (list[phase])
    }



    next()

    return {
        phase: phase,
        list: list,
        next: next
    }

}();

