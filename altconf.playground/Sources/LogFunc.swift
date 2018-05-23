import Foundation


public func LogFunc(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {

	// reduce this to a no-op when not in debug config
	// uncomment when run not running in a playground
//	#if DEBUG

	// make calls from non-main thread explicitly obvious
	let thread = (Thread.isMainThread) ? "" : " <Thread: \(threadNumberForThread(Thread.current))>\t"

	// get current milliseconds
	var detail_time: timeval = timeval(tv_sec: 0, tv_usec: 0)
	gettimeofday(&detail_time, nil)
	let miliseconds = String(format: ".%03d", detail_time.tv_usec / 1000)

	// get and format current time
	let time = NSDate().addingTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT(for: Date())))
	let fullString  = time.description
	let startIndex = fullString.index(fullString.startIndex, offsetBy: 11)
	let timeString = fullString[startIndex...]
	let endIndex = timeString.index(timeString.endIndex, offsetBy: -7)
	let timeMillisecondsString = "\(timeString[...endIndex])\(miliseconds)"

	let fileName = ((file as NSString).lastPathComponent as NSString).deletingPathExtension

	// attempt to align output for readability, by adding an "appropriate" number of tabs
	let fileNameThreshold: Double = 40
	let tabCount: Int = fileName.count > Int(fileNameThreshold) ? 1 : max(1, Int(pow((fileNameThreshold - Double(fileName.count)), 1.3) / 19))
	let padding = String(repeating:"\t", count:tabCount)

	let messageToPrint = (message.count > 0) ? ":\t\(message) " : ""
	let linePadding = "\(line)".count < 3 ? " " : ""
	print("\(timeMillisecondsString) \(fileName)\(padding)\("[\(line)]")\(linePadding)\t\(thread)\(function)\(messageToPrint)")

	// uncomment when run not running in a playground
//	#endif
}

private func threadNumberForThread(_ thread: Thread) -> String {
	let array1 = thread.description.components(separatedBy: ">")
	if array1.count > 1 {
		let array2 = array1[1].trimmingCharacters(in: CharacterSet(charactersIn: "{}")).components(separatedBy: ",")
		for pair in array2 {
			let array3 = pair.components(separatedBy: "=")
			if array3.count > 1 {
				if array3[0].contains("number") {
					return array3[1].trimmingCharacters(in: CharacterSet.whitespaces)
				}
			}
		}
	}
	return "(unknown)"
}
