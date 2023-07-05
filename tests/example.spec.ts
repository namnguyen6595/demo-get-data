import {
  test,
  expect,
  chromium,
  BrowserContext,
  Browser,
  Page,
  Locator,
} from "@playwright/test";

import { readFile, writeFile } from "fs/promises";
import { TECH_STACK } from "../data/constant";
import JSON2CSVParser from "@json2csv/plainjs/dist/mjs/Parser";
import { Parser } from "@json2csv/plainjs";
import { format } from "date-fns";

test.describe("Open page", () => {
  let browser: Browser;
  let context: BrowserContext;
  // let page: Page;
  test.beforeAll(async () => {});

  test("has title", async ({ page, browser }) => {
    await page.setExtraHTTPHeaders({
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
      "Accept-Language": "en-US,en;q=0.9",
    });
    const totalPage = 50; // Total page need crawl for each tech stack

    const listJobsData: any = []; // Define list of job for each stack. 50page * 15 job/page * total stack
    // Declare json file
    const dataFile = await readFile(
      require.resolve("../data/jobs.json"),
      "utf-8"
    );
    const dataCsv = JSON.parse(dataFile);

    /**
     * *Loop in tech stacks
     * @TECH_STACK: Declared in folder data.
     * * For each techstack will get data on 50 page
     * * Information crawl: Job name, description, posted date
     * @optional:  Salary, techstack in description
     */

    for (let stackIndex = 0; stackIndex < TECH_STACK.length; stackIndex++) {
      // Get stack in list
      const stack: string = TECH_STACK[stackIndex];

      // Define url will be filled into url of browser
      const url: string = `https://indeed.com/jobs?q=${stack}&l=&sort=date`;
      await page.waitForTimeout(3000);
      await page.goto(url);
      for (let count = 0; count < totalPage; count++) {
        const listJobs = page.locator(
          '//li/div[contains(@class, "job")]//table//td[@class="resultContent"]'
        ); // Elements of Job on row

        const totalJob: number = await listJobs.count(); // Count total job in each page. Example: 15

        for (let i = 0; i < totalJob; i++) {
          const jobName: string | null = await listJobs
            .nth(i)
            .locator("//h2//span")
            .first()
            .textContent();
          const companyName: string | null = await listJobs
            .nth(i)
            .locator(
              '//div[contains(@class,"company_location")]//span[@class="companyName"]'
            )
            .first()
            .textContent();
          const salaryElement: Locator = listJobs
            .nth(i)
            .locator(
              '//div[contains(@class, "salaryOnly")]/div[contains(@class, "salary")]/div'
            );
          const datePostedElement: string = await page
            .locator(
              '//li/div[contains(@class, "job")]//table//span[@class="date"]'
            )
            .nth(i)
            .innerText();
          let salary: string | null = "";
          const jobHasSalary = await salaryElement.isVisible();
          if (jobHasSalary) {
            salary = await salaryElement.first().textContent();
          }
          await listJobs.nth(i).locator("//h2//span").first().click();
          const jobDescription = await page
            .locator(
              '//div[@class="jobsearch-RightPane"]//div[@id="jobDescriptionText"]'
            )
            .first()
            .innerText();

          const convertDateToArray: string[] =
            datePostedElement.split("Posted ");
          let textDate: string =
            convertDateToArray[convertDateToArray.length - 1];
          switch (convertDateToArray[convertDateToArray.length - 1]) {
            case "Just posted":
              textDate = format(new Date(), "dd/MM/yyyy hh:mm");
              break;
            case "30+ days ago":
              textDate = "A month ago";
              break;
            default:
              break;
          }

          listJobsData.push({
            id: `${stack}_${count + 1}_${i + 1}`,
            name: jobName,
            companyName,
            salary: salary || "Not salary information",
            description: jobDescription,
            datePosted: textDate,
          });
          await page.waitForTimeout(500);
          writeFile(
            require.resolve("../data/jobs.json"),
            JSON.stringify({ jobs: listJobsData })
          );

          await page.waitForTimeout(1500);
          const fileName = format(new Date(), "dd_MM_yyyy");
          writeFile(__dirname + `/../data/${fileName}.csv`, "");
          if (!dataCsv.jobs.length) {
            continue;
          }
          try {
            const opts = {};
            const parser = new Parser(opts);
            const csv = parser.parse(dataCsv.jobs);

            writeFile(require.resolve(`../data/${fileName}.csv`), csv);
          } catch (error) {
            console.log({ error });
          }
        }
        await page.waitForTimeout(2000);
        // Next page
        const nextPageButton = page.locator(
          '//nav[@role="navigation"]//a[@data-testid="pagination-page-next"]'
        );
        const isHasNextPage = await nextPageButton.isVisible();
        if (isHasNextPage) {
          continue;
        }

        await page.waitForTimeout(3000);
      }
    }
  });
});
