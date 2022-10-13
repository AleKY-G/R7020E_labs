from tkinter import E
import cv2 as cv
import numpy as np
import yaml as yml
import pandas as pd
import sys

class Feature:
    def shape(self):
        """
            Returns a tuple of ints
        """
        pass

    def spacing(self):
        """
            Returns a tuple of the same number of elements that the shape returns
        """
        pass

    def __str__(self) -> str:
        return f"{type(self)}, shape = {self.shape()}, spacing = {self.spacing()}"

    def __repr__(self) -> str:
        return f"{type(self)}, shape = {self.shape()}, spacing = {self.spacing()}"


class CheckerBoard(Feature):
    def __init__(self, yaml):
        """
        initiates a new checkerboard
        """
        assert (yaml["target_type"] == "checkerboard")
        # Exprected shape
        self.shape_data = {
            "rows": yaml["targetRows"],
            "cols": yaml["targetCols"]
        }
        # Expected spacing
        self.spacing_data = {
            "row": yaml["rowSpacingMeters"],
            "col": yaml["colSpacingMeters"]
        }

    def shape(self):
        return (self.shape_data["rows"], self.shape_data["cols"])

    def spacing(self):
        return (self.spacing_data["row"], self.spacing_data["col"])


class Feed:
    def __init__(self, feed_path, csv_name):
        self.feed_path = feed_path
        data = pd.read_csv(csv_name).to_dict()
        self.time_stamps = data.keys()
        self.frames = data["filename"]

    def __iter__(self):
        # Let's just keep the end of the feed since runnning on every frame takes hours
        self.t = int(len(self.frames)*.80)
        return self

    def __next__(self):
        if self.t >= len(self.frames):
            raise StopIteration
        ret = cv.imread(f"{self.feed_path}/{self.frames[self.t]}")
        self.t += 1
        p = int((self.t/len(self.frames))*100)
        print("\r["+"="*p+">"+" "*(100-p)+f"] {self.t}/{len(self.frames)} ",end='\r')
        return ret


class Sensor:

    def load_feed(self, feed_path, file_name):
        self.feed = Feed(feed_path, file_name)

    def info(self):
        pass

    def extrinsics(self):
        pass

    def __str__(self) -> str:
        return f"{type(self)}, {self.info()}. Extrinsics = {self.extrinsics()}"

    def __repr__(self) -> str:
        return f"{type(self)}, {self.info()}. Extrinsics = {self.extrinsics()}"


class CalibratedSensor(Sensor):
    file_data = [
        "mtx",
        "dist",
        "rvecs",
        "tvecs"
    ]

    def __init__(self, extrinsics, mtx, dist, rvecs, tvecs):
        self.extrinsics = extrinsics
        self.mtx = mtx
        self.dist = dist
        self.rvecs = rvecs
        self.tvecs = tvecs

    def __getitem__(self, index):
        if index == "mtx":
            return self.mtx
        if index == "dist":
            return self.dist
        if index == "rvecs":
            return self.rvecs
        if index == "tvecs":
            return self.tvecs

    def save_calibration(self, folder_path):
        for file_name in self.file_data:
            with open(f"{folder_path}/{file_name}","w") as f:
                # Save the file
                f.write(str(self[file_name]))


class UncalibratedSensor(Sensor):
    def __init__(self, yaml):
        """
        Initiates a new sensor, this is used for calibration
        """
        self.comment = yaml["comment"]
        self.t_bs = yaml["T_BS"]

    def calibrate(self, feature: Feature):
        shape = feature.shape()
        spacing = feature.spacing()
        objp = np.zeros((shape[0]*shape[1], 3), np.float32)
        objp[:, :2] = np.mgrid[0:shape[0], 0:shape[1]].T.reshape(-1, 2)
        # Multiply with the spacing
        objp *= spacing[0]
        criteria = (cv.TERM_CRITERIA_EPS +
                    cv.TERM_CRITERIA_MAX_ITER, 30, 0.1)
        objpoints = []  # 3d point in real world space
        imgpoints = []  # 2d points in image plane.
        for frame in iter(self.feed):
            gray = cv.cvtColor(frame, cv.COLOR_RGB2GRAY)
            # Now we need to itterate over the frames in the feed
            # Find the chess board corners
            ret, corners = cv.findChessboardCorners(gray, (7, 6), None)
            # If found, add object points, image points (after refining them)
            if ret == True:
                objpoints.append(objp)
                corners2 = cv.cornerSubPix(
                    gray, corners, (11, 11), (-1, -1), criteria)
                imgpoints.append(corners)
                # Draw and display the corners
                #cv.drawChessboardCorners(frame, (7, 6), corners2, ret)
                #cv.imshow('img', frame)
                # cv.waitKey(500)
        # cv.destroyAllWindows()
        print(f"\nCalibrating the camera based on {len(objpoints)} elements")
        ret, mtx, dist, rvecs, tvecs = cv.calibrateCamera(
            objpoints, imgpoints, gray.shape[::-1], None, None)
        print(ret)
        return CalibratedSensor(self.extrinics(), mtx, dist, rvecs, tvecs)

    def info(self):
        self.comment

    def extrinics(self):
        self.t_bs


def load_yaml(file_name, parse_type):
    with open(file_name) as f:
        yaml = parse_type(yml.safe_load(f))
    return yaml


board_info = load_yaml("./calibration/checkerboard_7x6.yaml", CheckerBoard)
sensors = [
    load_yaml("calibration/mav0/cam0/sensor.yaml", UncalibratedSensor),
    load_yaml("calibration/mav0/cam1/sensor.yaml", UncalibratedSensor)
]
sensors[0].load_feed("calibration/mav0/cam0/data",
                     "calibration/mav0/cam0/data.csv")
sensors[1].load_feed("calibration/mav0/cam0/data",
                     "calibration/mav0/cam1/data.csv")

print(f"Board info = {board_info}")
print(f"Sensor info = {sensors}")
calibrated_sensor0 = sensors[0].calibrate(board_info)
calibrated_sensor0.save_calibration("calibration_data")
print("Calibrated sensor 0")
calibrated_sensor1 = sensors[1].calibrate(board_info)
calibrated_sensor1.save_calibration("calibration_data2")
print("Calibrated sensor 1")
