#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <string.h>
//#include <malloc.h>
#include <assert.h>
//#include <iostream>

#define _USE_MATH_DEFINES
#include <math.h>

#include "Eigen/Core"
#include "Eigen/Geometry"

#include "sophus/so3.hpp"
#include "sophus/se3.hpp"

/*
// A macro to disallow the copy constructor and operator= functions 
// This should be used in the priavte:declarations for a class
#define    DISALLOW_COPY_AND_ASSIGN(TypeName) \
    TypeName(const TypeName&);                \
    TypeName& operator=(const TypeName&)
*/

namespace mf {

typedef unsigned int u32;
typedef unsigned char u8;

typedef Eigen::Matrix<double, 6, 1> Vector6d;

class GlobalCoeff {
public:
	GlobalCoeff()
		: w(0)
		, h(0)
		, fx(0.0)
		, fy(0.0)
		, cx(0.0)
		, cy(0.0)
		, focallength(0.0)
	{
		Intrinsic.setZero();
	}

	GlobalCoeff(int w_, int h_, double fx_, double fy_, double cx_, double cy_, double fl_)
		: w(w_)
		, h(h_)
		, fx(fx_)
		, fy(fy_)
		, cx(cx_)
		, cy(cy_)
		, focallength(fl_)
	{
		Intrinsic.setIdentity();
		Intrinsic(0, 0) = fx;
		Intrinsic(1, 1) = fy;
		Intrinsic(0, 2) = cx;
		Intrinsic(1, 2) = cy;
	}

	int w, h;
	double fx, fy, cx, cy;
	double focallength;
	Eigen::Matrix3d Intrinsic;
};

extern GlobalCoeff G;

class CameraPose {
public:
	Eigen::Matrix3d intrinsics;
	Sophus::SE3d SE3_Rt;
	Eigen::Matrix3d R, Q;
	Eigen::Vector3d t, q;

	Eigen::Vector3d center;
	Vector6d se3;
	/*
	double3 rotation, translation, center, q;
	Matrix33d rot, Q, A;
	CameraPose(Matrix33d m, double a, double b, double r, double x, double y, double z) {
		rotation = double3(a, b, r);
		translation = double3(x, y, z);
		setMatrix();
		A = m;
		Q = A*rot;
		q = A*translation;
		center = -(inv(rot)*translation);
	}
	*/
	//w = Phi * n(x,y,z);
	/*
	CameraPose(Matrix33d m, AxisAngle w, double3 trans) {
	rot = w.toRotMatrix();
	translation = trans;
	A = m;
	refreshByARt();
	}*/
	CameraPose(Eigen::Matrix3d A, Eigen::Matrix3d rot, Eigen::Vector3d tran) {
		intrinsics = A;
		R = rot;
		t = tran;
		Q = intrinsics * R;
		q = intrinsics * t;

		SE3_Rt = Sophus::SE3d(R, t);
		se3 = SE3_Rt.log();
		center = -(R.inverse() * t);
	}
	CameraPose(Eigen::Matrix3d A, Sophus::SE3d _SE3) {
		intrinsics = A;
		SE3_Rt = _SE3;
		se3 = SE3_Rt.log();

		R = SE3_Rt.rotationMatrix();
		t = SE3_Rt.translation();
		Q = intrinsics * R;
		q = intrinsics * t;

		center = -(R.inverse() * t);
	}
	CameraPose(Eigen::Matrix3d A, Vector6d _se3) {
		intrinsics = A;
		se3 = _se3;
		SE3_Rt = Sophus::SE3d::exp(se3);

		R = SE3_Rt.rotationMatrix();
		t = SE3_Rt.translation();
		Q = intrinsics * R;
		q = intrinsics * t;

		center = -(R.inverse() * t);
	}
	//initiate by Euler
	CameraPose(Eigen::Matrix3d A, double rot1, double rot2, double rot3, double tran1, double tran2, double tran3) {
		intrinsics = A;
		setRByEuler(rot1, rot2, rot3);
		t[0] = tran1;
		t[1] = tran2;
		t[2] = tran3;
		refreshByARt();
	}
	//initiate by identity matrix
	CameraPose(Eigen::Matrix3d A) {
		intrinsics = A;
		R.setIdentity();
		t = Eigen::Vector3d(0.0, 0.0, 0.0);
		refreshByARt();
	}
	//initiate by quaternion
	CameraPose(Eigen::Matrix3d A, Eigen::Quaterniond q, Eigen::Vector3d t) {
		intrinsics = A;
		SE3_Rt = Sophus::SE3d(q, t);
		R = SE3_Rt.rotationMatrix();
		t = SE3_Rt.translation();
		refreshByARt();
	}
	CameraPose() {}

	void refreshByARt() {
		Q = intrinsics * R;
		q = intrinsics * t;
		SE3_Rt = Sophus::SE3d(R, t);
		se3 = SE3_Rt.log();
		center = -(R.inverse() * t);
	}
	void setRByEuler(double a, double b, double r) {
		R(0, 0) = double(cos(b)*cos(r));
		R(0, 1) = double(cos(b)*sin(r));
		R(0, 2) = double(-sin(b));
		R(1, 0) = double(-cos(a)*sin(r) + sin(a)*sin(b)*cos(r));
		R(1, 1) = double(cos(a)*cos(r) + sin(a)*sin(b)*sin(r));
		R(1, 2) = double(sin(a)*cos(b));
		R(2, 0) = double(sin(a)*sin(r) + cos(a)*sin(b)*cos(r));
		R(2, 1) = double(-sin(a)*cos(r) + cos(a)*sin(b)*sin(r));
		R(2, 2) = double(cos(a)*cos(b));
	}
	float* getViewMatrix() {
		float *v = (float*)malloc(sizeof(float) * 4 * 4);
		for (int i = 0; i < 3; i++) {
			for (int j = 0; j < 3; j++) {
				v[j * 4 + i] = R(i, j);
			}
			v[3 * 4 + i] = t[i];
		}
		v[0 * 4 + 3] = 0.0; v[1 * 4 + 3] = 0.0; v[2 * 4 + 3] = 0.0; v[3 * 4 + 3] = 1.0;
		return v;
	}
	/*
	double3 getRotation(Matrix33d m) {
		double3 tmp;
		//there are more than one solution for a rotation matrix, we choose one possible solution of them.
		if (m[0][2] != 1 && m[0][2] != -1) {
			tmp[1] = -(double)asin(m[0][2]);
			tmp[0] = (double)atan2(m[1][2] / cos(tmp[1]), m[2][2] / cos(tmp[1]));
			tmp[2] = (double)atan2(m[0][1] / cos(tmp[1]), m[0][0] / cos(tmp[1]));
		}
		else {
			tmp[2] = 0.0;
			if (m[0][2] == -1) {
				tmp[1] = double(M_PI) / 2;
				tmp[0] = tmp[2] + (double)atan2(m[1][0], m[2][0]);
			}
			else {
				tmp[1] = -double(M_PI) / 2;
				tmp[0] = tmp[2] + (double)atan2(-m[1][0], -m[2][0]);
			}
		}
		return tmp;
	}
	Matrix33d inv(Matrix33d m) {
		Matrix33d tmp;
		double3 m_r = getRotation(m);
		double a = -m_r[0];
		double b = -m_r[1];
		double r = -m_r[2];
		tmp[0][0] = double(cos(b)*cos(r));
		tmp[0][1] = double(sin(a)*sin(b)*cos(r) + cos(a)*sin(r));
		tmp[0][2] = double(-cos(a)*sin(b)*cos(r) + sin(a)*sin(r));
		tmp[1][0] = double(-cos(b)*sin(r));
		tmp[1][1] = double(-sin(a)*sin(b)*sin(r) + cos(a)*cos(r));
		tmp[1][2] = double(cos(a)*sin(b)*sin(r) + sin(a)*cos(r));
		tmp[2][0] = double(sin(b));
		tmp[2][1] = double(-sin(a)*cos(b));
		tmp[2][2] = double(cos(a)*cos(b));
		return tmp;
	}
	void setMatrix() {
		double a = rotation[0];
		double b = rotation[1];
		double r = rotation[2];
		rot[0][0] = double(cos(b)*cos(r));
		rot[0][1] = double(cos(b)*sin(r));
		rot[0][2] = double(-sin(b));
		rot[1][0] = double(-cos(a)*sin(r) + sin(a)*sin(b)*cos(r));
		rot[1][1] = double(cos(a)*cos(r) + sin(a)*sin(b)*sin(r));
		rot[1][2] = double(sin(a)*cos(b));
		rot[2][0] = double(sin(a)*sin(r) + cos(a)*sin(b)*cos(r));
		rot[2][1] = double(-sin(a)*cos(r) + cos(a)*sin(b)*sin(r));
		rot[2][2] = double(cos(a)*cos(b));
	}*/
};

template<typename T> 
T binterd(T* I_i, double vx, double vy, int size) {
	int z_x = int(vx + 0.00001);  //0~w
	int z_y = int(vy + 0.00001);  //0~h
	double x = vx - z_x;
	double y = vy - z_y;
	//if (z_x < 0 || z_x + 1 >= g_w || z_y < 0 || z_y + 1 >= g_h) return T(0);
	return T((1.0 - x)   * (1.0 - y)  * I_i[z_y	 *size + z_x] +
			  x			 * (1.0 - y)  * I_i[z_y	 *size + z_x + 1] +
			  x          *  y	      * I_i[(z_y + 1)*size + z_x + 1] +
			 (1.0 - x)   *  y	      * I_i[(z_y + 1)*size + z_x]);
}

static u32 binterd_u32(u32 *I, double vx, double vy, int size) {
	int z_x = int(vx + 1e-5);
	int z_y = int(vy + 1e-5);
	double x = vx - z_x;
	double y = vy - z_y;

	int a = (1.0 - x)	* (1.0 - y) * (I[(z_y)	* size + z_x] >> 24) +
			(x)			* (1.0 - y) * (I[(z_y)	* size + z_x + 1] >> 24) +
			(x)			* (y)		* (I[(z_y+1)* size + z_x + 1] >> 24) +
			(1.0 - x)	* (y)		* (I[(z_y+1)* size + z_x] >> 24);

	int b = (1.0 - x)	* (1.0 - y) * (I[(z_y)	* size + z_x] >> 16 & 0xff) +
			(x)			* (1.0 - y) * (I[(z_y)	* size + z_x + 1] >> 16 & 0xff) +
			(x)			* (y)		* (I[(z_y+1)* size + z_x + 1] >> 16 & 0xff) +
			(1.0 - x)	* (y)		* (I[(z_y+1)* size + z_x] >> 16 & 0xff);

	int g = (1.0 - x)	* (1.0 - y) * (I[(z_y)	* size + z_x] >> 8 & 0xff) +
			(x)			* (1.0 - y) * (I[(z_y)	* size + z_x + 1] >> 8 & 0xff) +
			(x)			* (y)		* (I[(z_y+1)* size + z_x + 1] >> 8 & 0xff) +
			(1.0 - x)	* (y)		* (I[(z_y+1)* size + z_x] >> 8 & 0xff);

	int r = (1.0 - x)	* (1.0 - y) * (I[(z_y)	* size + z_x] & 0xff) +
			(x)			* (1.0 - y) * (I[(z_y)	* size + z_x + 1] & 0xff) +
			(x)			* (y)		* (I[(z_y+1)* size + z_x + 1] & 0xff) +
			(1.0 - x)	* (y)		* (I[(z_y+1)* size + z_x] & 0xff);

	return u32(a << 24 | b << 16 | g << 8 | r);
}

static float rgba2gray(u32 rgba) {
	float a = static_cast<float>(rgba >> 24);
	float b = static_cast<float>(rgba >> 16 & 0xff);
	float g = static_cast<float>(rgba >> 8  & 0xff);
	float r = static_cast<float>(rgba       & 0xff);

	if (a == 0.0) return 0.0;
	else return r*0.299 + g*0.587 + b*0.114;
}

} //namespace mf

#endif //UTILS_H
