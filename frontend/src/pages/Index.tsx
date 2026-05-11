import React from "react";
import HeroSection from "@/components/HeroSection";
import CreateLink from "@/components/CreateLink";

const Index: React.FC = () => {
  return (
    <div className="container py-10 lg:py-14 max-w-6xl">
      <HeroSection />
      <div id="create" className="scroll-mt-20">
        <CreateLink />
      </div>
    </div>
  );
};

export default Index;
