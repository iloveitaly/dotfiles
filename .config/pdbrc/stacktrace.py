# stacktrace.py
import inspect


def print_stack():
    current_frame = (
        inspect.currentframe().f_back.f_back
    )  # Get the frame of the caller of this function
    all_frames = inspect.getouterframes(current_frame)
    for i, frame_info in enumerate(reversed(all_frames)):
        marker = "=> " if frame_info.frame is current_frame else "   "
        print(
            f"{marker}#{i} {frame_info.filename}:{frame_info.lineno} in {frame_info.function}"
        )


if __name__ == "__main__":
    print_stack()
