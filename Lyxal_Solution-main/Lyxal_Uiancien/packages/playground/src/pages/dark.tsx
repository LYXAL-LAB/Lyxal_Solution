import React from 'react';
import { Main } from '../layouts';
import { Component } from '../components';

const DarkPage: React.FC = () => {
  return (
    <Main theme="dark">
      <Component />
    </Main>
  );
};

export default DarkPage;
