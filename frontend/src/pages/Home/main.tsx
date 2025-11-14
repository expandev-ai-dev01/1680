export const HomePage = () => {
  return (
    <div className="space-y-6">
      <div className="rounded-lg bg-white p-6 shadow">
        <h2 className="text-xl font-semibold text-gray-900">Welcome to AutoClean</h2>
        <p className="mt-2 text-gray-600">
          A simple script to identify and remove temporary or duplicate files from a folder.
        </p>
      </div>
      <div className="rounded-lg bg-white p-6 shadow">
        <h3 className="text-lg font-medium text-gray-900">Getting Started</h3>
        <p className="mt-2 text-gray-600">
          Select a folder to scan for temporary files and duplicates.
        </p>
      </div>
    </div>
  );
};

export default HomePage;
