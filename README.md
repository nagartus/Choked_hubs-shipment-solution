Analysis Report: Shipment Warehouse Performance     (dataset- https://drive.google.com/file/d/1YiFaiq2L1yQSMQrAQ8ERBgSJ21OQ89cs/view?usp=share_link)
Introduction
This report presents an analysis of shipment data to iden􏰀fy and priori􏰀ze warehouses that may be facing opera􏰀onal challenges leading to delays. The data is sourced from a dataset containing shipment details, including the latest status, loca􏰀on, and journey details. The analysis aims to highlight warehouses that require immediate a􏰁en􏰀on and those that can be priori􏰀zed for clearing based on defined metrics.
Data Extrac􏰀on and Cleaning:
During the data extrac􏰀on and cleaning phase of our internship assignment, challenges arose while impor􏰀ng a JSON file into MySQL Workbench. Despite a􏰁empts to correct forma􏰂ng issues, encountered errors persisted. To address this, we transformed the JSON data into a CSV file, facilita􏰀ng smoother importa􏰀on.
Given the substan􏰀al dataset, we ini􏰀ally faced "list index out of range" errors during array processing. Mi􏰀ga􏰀ng this, we analysed a subset of 100 lines successfully. Realizing the need for a more efficient approach, we leveraged a Python script for data cleaning.
Specifically, we adopted a strategy to address missing values in the "loca􏰀on" a􏰁ribute. For a given shipment ID with mul􏰀ple loca􏰀ons, we filled the missing values by considering the last available loca􏰀on. If no latest loca􏰀on existed, we are dele􏰀ng that row and rest all missing rows are deleted and the reason behind this is:
1) When the preceding and succeeding values are iden􏰀cal, it signifies a con􏰀nuous state, ensuring that the parcel remains within the same warehouse. Filling such rows with redundant informa􏰀on would compromise data integrity, as the informa􏰀on provided by the iden􏰀cal loca􏰀ons is inherently inconsequen􏰀al and redundant to the overall dataset. Dele􏰀ng these rows preserves the meaningful representa􏰀on of the data without introducing superfluous or duplicated values.
2) When the values before and a􏰃er a missing entry differ significantly, it signifies a transient state. Dele􏰀ng rows in these instances enhances data coherence, ensuring that the dataset accurately reflects per􏰀nent and non-redundant informa􏰀on, aligning with best prac􏰀ces in data management and analysis.
This approach was crucial in resolving missing data intricacies and was executed seamlessly with the Python script provided.
The decision to shi􏰃 from SQL to Python was driven by the complexity and error-prone nature of SQL queries in handling the diverse challenges encountered during the internship. This strategy not only ensured accurate data cleaning but also streamlined the process for enhanced efficiency and clarity in the final dataset.
Performance Metrics Calcula􏰀on
Percentage of Delayed Shipments
The primary metric used for warehouse analysis is the percentage of delayed shipments. A delay is defined as a 􏰀me difference exceeding a threshold (e.g., 2 days) between consecu􏰀ve 􏰀mestamps (c􏰀me). This percentage is calculated for each loca􏰀on using the formula:
Percentage Delayed = (Number of Delayed Shipments/Total Shipments) * 100
Warehouse Status Classifica􏰀on
Based on the percentage of delayed shipments, warehouses are classified into three categories:
Need Immediate A􏰁en􏰀on: If the latest status is 'SHIPMENT DELAYED,' it signifies a need for immediate ac􏰀on.
Priori􏰀ze for Clearing: If the percentage of delayed shipments exceeds a defined threshold (e.g., 20%), the warehouse is priori􏰀zed for clearing.
Ignore: Warehouses that do not fall into the above categories are marked as 'Ignore.' Results
The analysis results are stored in the analysis results table, providing insights into the performance of each warehouse.
Conclusion
This analysis provides a systema􏰀c approach to iden􏰀fy and priori􏰀ze warehouses based on their performance metrics. The classifica􏰀on allows for efficient resource alloca􏰀on, focusing on warehouses with immediate needs and those requiring priori􏰀zed clearing efforts. The approach is flexible, allowing for adjustments to threshold values based on opera􏰀onal requirements.
Feel free to tailor the report to be􏰁er match your specific context, add more details, or provide addi􏰀onal insights based on the results of your analysis.
