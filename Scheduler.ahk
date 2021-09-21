class Scheduler {
    static scheduleList := []
    static dispatchBox := ""

    __new(list) {
        if (list.Length) {
            Scheduler.dispatchBox := ""
            Scheduler.scheduleList := list
            timer := ObjBindMethod(Scheduler, "ManageDispatcher")
            SetTimer(timer, -1000)
        }
    }

    static ManageDispatcher() {

        timer := ObjBindMethod(Scheduler, "DispatchJob")
        SetTimer(timer, -1000)
    }

    static DispatchJob() {
        static sList := ""
        if (Scheduler.dispatchBox and sList == Scheduler.scheduleList) {
            ; scheduleList := Scheduler.scheduleList
            dispatchBox := Scheduler.dispatchBox
        } else if(!Scheduler.dispatchBox) {
            sList := Scheduler.scheduleList
            Scheduler.dispatchBox := []
        } else {
            return
        }

        timer := ObjBindMethod(Scheduler, "DispatchJob")
        SetTimer(timer, -1000)
    }
}
