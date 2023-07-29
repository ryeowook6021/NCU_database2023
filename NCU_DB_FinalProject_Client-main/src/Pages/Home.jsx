import React from "react";

const Home = () => {
  return (
    <div className="flex align-center justify-start m-4 mx-20 mt-32">
      <section className="lg:mx-24 mx-5 ">
        <div className=" my-10 invisible md:invisible md:w-0">
          {/* <img src="/" /> */}
        </div>
        <h1 className=" text-5xl md:mt-72 text-yellow-700 mb-4 font-bold">
          交易模擬系統
        </h1>
        <p className=" ">
          讓<span className="text-yellow-700 font-extrabold text-xl">交易</span>
        </p>
        <p className="">更簡單</p>
        <div className="mt-2">
          <button
            type="submit"
            className="my-4 mr-4 px-4 py-2 font-bold bg-yellow-700 rounded-lg text-white w-30 h-10"
          >
            <a href="/Trade">Trade Now</a>
          </button>
          <button
            type="submit"
            className="my-4 mr-4 px-4 py-2 font-bold bg-yellow-700 rounded-lg text-white w-30 h-10"
          >
            <a href="/strategy">Find Strategy</a>
          </button>
        </div>
      </section>
      <section>
        <div className=" w-0 mt-48 invisible lg:visible lg:w-96">
          {/* <img src="/" /> */}
        </div>
      </section>
    </div>
  );
};

export default Home;
